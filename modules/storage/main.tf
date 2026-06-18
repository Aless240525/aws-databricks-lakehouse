# 1. Obtener información de tu cuenta de AWS actual para generar nombres únicos
data "aws_caller_identity" "current" {}

# 2. Creación del Root Bucket (Uso exclusivo interno de Databricks)
resource "aws_s3_bucket" "root_storage" {
  bucket        = "${var.prefix}-root-${data.aws_caller_identity.current.account_id}"
  force_destroy = true # Permite destruir el bucket aunque tenga logs adentro
  tags          = merge(var.tags, { Name = "${var.prefix}-root-storage" })
}

# Deshabilitar control de versiones en el Root Bucket (Recomendación oficial de Databricks)
resource "aws_s3_bucket_versioning" "root_versioning" {
  bucket = aws_s3_bucket.root_storage.id
  versioning_configuration {
    status = "Suspended"
  }
}

# 3. Política de seguridad para el Root Bucket
# Permite que el rol "Cross-Account" de Databricks pueda interactuar con el bucket
data "aws_iam_policy_document" "root_storage_policy" {
  statement {
    sid = "GrantDatabricksAccess"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl"
    ]
    resources = ["${aws_s3_bucket.root_storage.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [var.cross_account_role_arn]
    }
  }
  statement {
    sid = "GrantDatabricksList"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [aws_s3_bucket.root_storage.arn]
    principals {
      type        = "AWS"
      identifiers = [var.cross_account_role_arn]
    }
  }
}

# Adjuntar la política al Root Bucket
resource "aws_s3_bucket_policy" "root_storage" {
  bucket = aws_s3_bucket.root_storage.id
  policy = data.aws_iam_policy_document.root_storage_policy.json
}

# 4. Creación del Data Bucket (Para tu Lakehouse: Raw, Silver, Gold)
resource "aws_s3_bucket" "lakehouse_data" {
  bucket        = "${var.prefix}-data-${data.aws_caller_identity.current.account_id}"
  force_destroy = true 
  tags          = merge(var.tags, { Name = "${var.prefix}-data-storage" })
}

# En el Data Bucket sí es buena práctica activar el versionado para proteger tus tablas Delta
resource "aws_s3_bucket_versioning" "data_versioning" {
  bucket = aws_s3_bucket.lakehouse_data.id
  versioning_configuration {
    status = "Enabled"
  }
}