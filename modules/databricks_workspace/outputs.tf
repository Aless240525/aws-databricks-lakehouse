output "workspace_url" {
  description = "La URL para acceder al Workspace de Databricks"
  value       = databricks_mws_workspaces.this.workspace_url
}