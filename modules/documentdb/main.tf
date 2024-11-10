locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

resource "aws_docdb_subnet_group" "default" {
  name       = "${var.project}-${var.environment}-docdb"
  subnet_ids = var.subnet_ids

  tags = local.common_tags
}

resource "aws_docdb_cluster_parameter_group" "default" {
  family      = "docdb5.0"
  name        = "${var.project}-${var.environment}-docdb"
  description = "DocumentDB cluster parameter group for ${var.project}-${var.environment}"

  parameter {
    name         = "tls"
    value        = var.tls_enabled ? "enabled" : "disabled"
    apply_method = "pending-reboot"
  }

  tags = local.common_tags
}

resource "aws_docdb_cluster" "default" {
  cluster_identifier              = "${var.project}-${var.environment}"
  engine                          = "docdb"
  master_username                 = var.master_username
  master_password                 = var.master_password
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = "07:00-09:00"
  skip_final_snapshot             = true
  deletion_protection             = var.deletion_protection
  db_subnet_group_name            = aws_docdb_subnet_group.default.name
  vpc_security_group_ids          = [var.documentdb_sg_id]
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.default.name
  apply_immediately               = var.apply_immediately

  tags = local.common_tags
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = var.instance_count
  identifier         = "${var.project}-${var.environment}-${count.index}"
  cluster_identifier = aws_docdb_cluster.default.id
  instance_class     = var.instance_class

  tags = local.common_tags
}