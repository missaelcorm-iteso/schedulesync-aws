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
  password_length = 24
  exclude_numbers = false 
  exclude_punctuation = true 
  include_space = false 
}

# Create Secrets Manager secret for DocumentDB credentials
resource "aws_secretsmanager_secret" "docdb_credentials" {
  name        = "${var.project}-${var.environment}-docdb-credentials"
  description = "DocumentDB credentials for ${var.project}-${var.environment}"

  tags = local.common_tags
}

# Store the credentials in Secrets Manager
resource "aws_secretsmanager_secret_version" "docdb_credentials" {
  secret_id = aws_secretsmanager_secret.docdb_credentials.id
  secret_string = jsonencode({
    username = random_string.master_username.result
    password = data.aws_secretsmanager_random_password.master_password.random_password
    host     = var.docdb_host
    port     = var.docdb_port
    dbname   = var.docdb_name
  })
}
