variable "vpc_name" {
  description = "Nombre de la VPC"
  type        = string
}

variable "cidr_block" {
  description = "Rango de IPs de la VPC"
  type        = string
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
}

variable "tags" {
  description = "Etiquetas base para los recursos"
  type        = map(string)
}