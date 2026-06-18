variable "prefix" {
  description = "Prefijo para nombrar el workspace"
  type        = string
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
}

variable "cross_account_role_arn" {
  description = "ARN del rol IAM para Databricks"
  type        = string
}

variable "root_bucket_name" {
  description = "Nombre del S3 Root Bucket"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC principal"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de IDs de las subredes privadas (mínimo 2)"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID del Security Group para los nodos"
  type        = string
}

variable "tags" {
  description = "Etiquetas base"
  type        = map(string)
}

variable "databricks_account_id" {
  description = "ID de la cuenta de Databricks"
  type        = string
}