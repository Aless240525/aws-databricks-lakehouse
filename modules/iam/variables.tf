variable "prefix" {
  description = "Prefijo para nombrar recursos"
  type        = string
}

variable "databricks_account_id" {
  description = "ID de tu cuenta de Databricks (usado como External ID por seguridad)"
  type        = string
}

variable "tags" {
  description = "Etiquetas base"
  type        = map(string)
}