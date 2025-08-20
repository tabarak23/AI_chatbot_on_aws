#postgresql rds with secret manager 
locals {
  name ="${var.project_name}-${var.stage}"
  create_db =!var.import_db
  
  # Define fallback values for DB endpoints and connection info
  db_endpoint_fallback= "${local.name}-postgres.${var.aws_region}.rds.amazonaws.com"
  db_port_fallback =5432
  
  # We'll use these for conditional logic
  common_tags = {
    Project= var.project_name
    Environment= var.stage
    ManagedBy= "Terraform"
  }
}


data "aws_db_instance" "postgres" {
  count = var.import_db ? 1 : 0
  db_instance_identifier = "${local.name}-postgres"
}

#create a random password for the database
resource "random_password" "postgres_password" {
  count = local.create_db ? 1 : 0  
  length= 16
  special= true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  
  lifecycle {
    ignore_changes = all
  }
}


# ====================================================================
# Use a null_resource to check if the DB exists instead of data source
# ====================================================================

resource "null_resource" "db_existence_check" {
  count = var.import_db ? 1 : 0
  
  # This will run during plan phase to check if the DB exists
  provisioner "local-exec" {
    command = <<EOF
      aws rds describe-db-instances --db-instance-identifier ${local.name}-postgres > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        echo "DB exists"
        exit 0
      else
        echo "DB does not exist, but import_db is set to true. Setting create_db to true."
        exit 0  # Continue anyway
      fi
    EOF
  }
}


resource "aws_db_instance" "dummy_for_import" {
  count = 0  # Never create this

  identifier= "${local.name}-postgres"
  engine= "postgres"
  instance_class= var.db_instance_class
  allocated_storage= var.db_allocated_storage
  skip_final_snapshot= true
  apply_immediately= true

  lifecycle {
    prevent_destroy = true
  }
}
#db parameter group

resource "aws_db_parameter_group" "postgres" {
  count = local.create_db ? 1 : 0
  name= "${local.name}-postgres-params"
  family= "postgres${var.db_engine_version}"
  description= "Parameter group for ${local.name} PostgreSQL database"

  # Add parameters with proper apply_method
  parameter {
    name = "shared_preload_libraries"
    value ="pg_stat_statements,auto_explain"
    apply_method= "pending-reboot"  # This is critical - static parameters require a reboot
  }
  
  tags = {
    Name ="${local.name}-postgres-params"
  }
  
  lifecycle {
    create_before_destroy= true
    prevent_destroy= true
  }
}
#creating rds if ot doesnt there

resource "aws_db_instance" "postgres" {
  # Only create if import_db is false
  count = local.create_db ? 1 : 0
  
  identifier= "${local.name}-postgres"
  engine= "postgres"
  engine_version= var.db_engine_version
  instance_class= var.db_instance_class
  allocated_storage= var.db_allocated_storage
  storage_type= "gp3"
  db_name= var.db_name
  username= var.db_username
  password= random_password.postgres_password[count.index].result
  db_subnet_group_name= var.db_subnet_group_name
  vpc_security_group_ids= [var.db_security_group_id]
  skip_final_snapshot= var.skip_final_snapshot
  apply_immediately= true
  backup_retention_period = 7
  parameter_group_name= aws_db_parameter_group.postgres[count.index].name
  
  # Performance insights
  performance_insights_enabled= true
  performance_insights_retention_period = 7
  
  tags = {
    Name = "${local.name}-postgres"
    Environment = var.stage
  }
  
  lifecycle {
    prevent_destroy = true
    ignore_changes = [password]
  }
}
#storing sects in secrets manager

resource "aws_secretsmanager_secret" "db_credentials" {
  count = local.create_db ? 1 : 0
  name= "${local.name}-db-credentials"
  description= "Database credentials for ${local.name}"
  
  tags = {
    Name = "${local.name}-db-credentials"
    Environment= var.stage
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  count = local.create_db ? 1 : 0  
  secret_id = aws_secretsmanager_secret.db_credentials[count.index].id
  secret_string= jsonencode({
    username =var.db_username
    password= random_password.postgres_password[count.index].result
    engine= "postgres"
    host= aws_db_instance.postgres[count.index].address
    port= aws_db_instance.postgres[count.index].port
    dbname= var.db_name
  })
}