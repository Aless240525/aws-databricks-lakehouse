# 1. Registrar las credenciales IAM en Databricks
# Le decimos a la plataforma de Databricks que este rol existe en tu AWS
resource "databricks_mws_credentials" "this" {
  provider         = databricks.mws
  account_id       = var.databricks_account_id
  role_arn         = var.cross_account_role_arn
  credentials_name = "${var.prefix}-creds"
}

# 2. Registrar el Root Bucket en Databricks
resource "databricks_mws_storage_configurations" "this" {
  provider                   = databricks.mws
  account_id                 = var.databricks_account_id
  bucket_name                = var.root_bucket_name
  storage_configuration_name = "${var.prefix}-storage"
}

# 3. Registrar la Red (VPC, Subnets, SG) en Databricks
resource "databricks_mws_networks" "this" {
  provider           = databricks.mws
  account_id         = var.databricks_account_id
  network_name       = "${var.prefix}-network"
  security_group_ids = [var.security_group_id]
  subnet_ids         = var.private_subnet_ids
  vpc_id             = var.vpc_id
}

# 4. Creación del Workspace de Databricks
resource "databricks_mws_workspaces" "this" {
  provider        = databricks.mws
  account_id      = var.databricks_account_id
  aws_region      = var.aws_region
  workspace_name  = "${var.prefix}-workspace"
  
  # Usamos los IDs de los registros que acabamos de crear arriba
  credentials_id           = databricks_mws_credentials.this.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id               = databricks_mws_networks.this.network_id

  # Esperar a que el Workspace esté corriendo antes de dar por terminado Terraform
  depends_on = [
    databricks_mws_networks.this
  ]
}