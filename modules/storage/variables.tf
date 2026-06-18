variable "prefix" {
  description = "Prefijo para nombrar los buckets"
  type        = string
}

variable "cross_account_role_arn" {
  description = "ARN del rol de Databricks para darle permisos sobre el Root Bucket"
  type        = string
}

variable "tags" {
  description = "Etiquetas base"
  type        = map(string)
}