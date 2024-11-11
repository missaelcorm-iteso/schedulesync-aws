output "docdb_secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret containing DocumentDB credentials"
  value       = aws_secretsmanager_secret.docdb_credentials.arn
}

output "docdb_secrets_manager_secret_name" {
  description = "Name of the Secrets Manager secret containing DocumentDB credentials"
  value       = aws_secretsmanager_secret.docdb_credentials.name
}

output "docdb_credentials_master_username" {
  description = "Master username for DocumentDB"
  value       = random_string.master_username.result
  sensitive   = true
}

output "docdb_credentials_master_password" {
  description = "Master password for DocumentDB"
  value       = aws_secretsmanager_secret_version.master_password.secret_string
  sensitive   = true
}

output "backend_jwt_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the JWT secret for the backend"
  value       = aws_secretsmanager_secret.app_jwt_secret.arn
}