# main.tf en la raíz del proyecto

# Definición de variables locales para estandarizar nombres
locals {
  prefix = "lakehouse-${var.entorno}-${var.proyecto}"
  tags = {
    Environment = var.entorno
    Project     = var.proyecto
    ManagedBy   = "Terraform"
  }
}

# 1. Llamada al módulo de red (VPC)
module "vpc" {
  source = "./modules/vpc"

  vpc_name   = "${local.prefix}-vpc"
  cidr_block = var.vpc_cidr_block
  aws_region = var.aws_region
  tags       = local.tags
}

# 2. Llamada al módulo de IAM (Roles y Permisos)
module "iam" {
  source = "./modules/iam"

  prefix                = local.prefix
  databricks_account_id = var.databricks_account_id
  tags                  = local.tags
}

# 3. Llamada al módulo de Storage (S3 Buckets)
module "storage" {
  source = "./modules/storage"

  prefix                 = local.prefix
  cross_account_role_arn = module.iam.cross_account_role_arn
  tags                   = local.tags
}