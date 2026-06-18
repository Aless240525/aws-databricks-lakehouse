terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # AGREGAMOS EL PROVEEDOR OFICIAL DE DATABRICKS
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.30"
    }
  }

  backend "s3" {
    bucket         = "lakehouse-terraform-state-joaquin"
    key            = "global/mystate/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "lakehouse-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}

# CONFIGURACIÓN DEL PROVEEDOR DATABRICKS (NIVEL DE CUENTA)
provider "databricks" {
  alias    = "mws"
  host     = "https://accounts.cloud.databricks.com"
  # Las credenciales de Databricks (Client ID y Secret) se pasarán por variables de entorno más adelante.
}
