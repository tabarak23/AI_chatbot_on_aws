variable "project_name" {
  description = "name of the project"
  type= string
}

variable "stage" {
  description = "seployment stage (dev, staging, prod)"
  type= string
}

variable "aws_region" {
  description = "aws region"
  type= string
}

variable "vpc_cidr" {
  description = "cidr block for the vpc"
  type= string
  default= "10.0.0.0/16"
}

variable "az_count" {
  description = "number of availability zones to use"
  type= number
  default= 2
}

variable "single_nat_gateway" {
  description = "use a single nat Gateway instead of one per az (cost saving for dev)"
  type= bool
  default= false
}

variable "enable_flow_logs" {
  description = "enable vpc flow Logs for network monitoring"
  type= bool
  default= false
}

variable "create_bastion_sg" {
  description = "create a security group for bastion hosts"
  type= bool
  default= false
}

variable "bastion_allowed_cidr" {
  description = "cidr blocks allowed to connect to bastion hosts"
  type= list(string)
  default= ["0.0.0.0/0"]
}