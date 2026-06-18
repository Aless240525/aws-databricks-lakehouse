output "root_bucket_name" {
  description = "Nombre del Root Bucket (Requerido por Databricks Workspace)"
  value       = aws_s3_bucket.root_storage.bucket
}

output "data_bucket_name" {
  description = "Nombre del Data Bucket (Para configurar Unity Catalog después)"
  value       = aws_s3_bucket.lakehouse_data.bucket
}