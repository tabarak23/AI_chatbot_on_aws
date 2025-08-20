

#API Module
variable "project_name" {
  description = "name of the project"
  type= string
}

variable "stage" {
  description = "deployment stage (dev, staging, prod)"
  type= string
}

variable "aws_region" {
  description = "aws region for all resources"
  type= string
  default= "us-west-1"
}

variable "document_processor_arn" {
  description = "arn of the document processor lambda function"
  type= string
}

variable "query_processor_arn" {
  description = "arn of the query processor lambda function"
  type= string
}

variable "upload_handler_arn" {
  description = "arn of the upload handler lambda function"
  type= string
}

variable "query_processor_name" {
  description = "name of the query processor lambda function"
  type= string
}

variable "upload_handler_name" {
  description = "Name of the upload handler lambda function"
  type= string
}

variable "auth_handler_arn" {
  description = "arn of the auth handler lambda function"
  type= string
}

variable "auth_handler_name" {
  description = "name of the auth handler lambda function"
  type= string
}

variable "cognito_user_pool_id" {
  description = "id of the cognito User pool"
  type= string
}

variable "cognito_app_client_id" {
  description = "id of the cognito app client"
  type= string
}

variable "cognito_user_pool_arn" {
  description = "arn of the cognito User pool"
  type= string
}

variable "cognito_domain" {
  type = string
}