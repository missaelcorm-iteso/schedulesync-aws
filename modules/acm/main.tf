terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

locals {
  name_prefix = "${var.project}-${var.environment}"
  
  # Combine main domain and alternative names
  domain_names = distinct(concat([var.domain_name], var.subject_alternative_names))
}

# Create ACM certificate
resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  tags = {
    Name        = "${local.name_prefix}-certificate"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create DNS validation records in Cloudflare
resource "cloudflare_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  value   = each.value.record
  type    = each.value.type
  ttl     = 60
  proxied = false # Important: DNS validation records should not be proxied
}

# Validate the certificate
resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in cloudflare_record.acm_validation : record.hostname]
}