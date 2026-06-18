# variables.tf en la raíz del proyecto

variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type        = string
  default     = "us-east-2" 
}

variable "entorno" {
  description = "Entorno de despliegue (ej. dev, qa, prod)"
  type        = string
  default     = "dev"
}

variable "proyecto" {
  description = "Nombre corto del proyecto"
  type        = string
  default     = "databricks"
}

variable "vpc_cidr_block" {
  description = "Rango CIDR para la VPC principal"
  type        = string
  default     = "10.0.0.0/16"
}

variable "databricks_account_id" {
  description = "El ID de la cuenta en accounts.cloud.databricks.com"
  type        = string
  default     = "1234567890123456" # Pon un valor de prueba temporalmente
}