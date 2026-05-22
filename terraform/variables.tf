variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
  default     = "us-east-1"
}

variable "table_name" {
  type        = string
  description = "Nombre de la tabla DynamoDB compartida para almacenar las URLs"
  default     = "UrlsTable"
}
