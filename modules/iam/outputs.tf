output "cross_account_role_arn" {
  description = "El ARN del rol que Databricks usará"
  value       = aws_iam_role.cross_account_role.arn
}