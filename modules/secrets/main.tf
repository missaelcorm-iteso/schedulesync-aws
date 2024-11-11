locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

resource "random_string" "master_username" {
  length  = 8
  special = false
  numeric = false
  upper   = false
}

data "aws_secretsmanager_random_password" "master_password" {
  password_length     = 24
  exclude_numbers     = false
  exclude_punctuation = true
  include_space       = false
}

resource "aws_secretsmanager_secret" "master_password" {
  name                    = "${var.project}-${var.environment}-docdb-master-password"
  description             = "Master password for DocumentDB"
  recovery_window_in_days = var.docdb_recovery_window_in_days

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "master_password" {
  secret_id     = aws_secretsmanager_secret.master_password.id
  secret_string = data.aws_secretsmanager_random_password.master_password.random_password

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Create Secrets Manager secret for DocumentDB credentials
resource "aws_secretsmanager_secret" "docdb_credentials" {
  name                    = "${var.project}-${var.environment}-docdb-credentials"
  description             = "DocumentDB credentials for ${var.project}-${var.environment}"
  recovery_window_in_days = var.docdb_recovery_window_in_days

  tags = local.common_tags
}

# Store the credentials in Secrets Manager
resource "aws_secretsmanager_secret_version" "docdb_credentials" {
  secret_id = aws_secretsmanager_secret.docdb_credentials.id
  secret_string = jsonencode({
    username = random_string.master_username.result
    password = aws_secretsmanager_secret_version.master_password.secret_string
    host     = var.docdb_host
    port     = var.docdb_port
    dbname   = var.docdb_name
  })
}

data "aws_secretsmanager_random_password" "app_jwt_secret" {
  password_length     = 64
  exclude_numbers     = false
  exclude_punctuation = true
  include_space       = false
}

resource "aws_secretsmanager_secret" "app_jwt_secret" {
  name                    = "${var.project}-${var.environment}-app-jwt-secret"
  description             = "JWT secret for the application"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "backend_jwt_secret" {
  secret_id = aws_secretsmanager_secret.app_jwt_secret.id
  secret_string = jsonencode({
    secretkey = data.aws_secretsmanager_random_password.app_jwt_secret.random_password
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}
