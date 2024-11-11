terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

locals {
  name_prefix = "${var.project}-${var.environment}"
  domain_name = "${local.name_prefix}.${var.root_domain}"

  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# Create ACM certificate
resource "aws_acm_certificate" "main" {
  domain_name = local.domain_name
  subject_alternative_names = [
    "api-${local.domain_name}"
  ]
  validation_method = "DNS"

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-cert"
  })

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

  zone_id         = var.cloudflare_zone_id
  name            = trimsuffix(each.value.name, ".${var.root_domain}.")
  content         = each.value.record
  type            = each.value.type
  ttl             = 60
  proxied         = false # Important: DNS validation records should not be proxied
  allow_overwrite = true

  lifecycle {
    create_before_destroy = true
    replace_triggered_by = [
      aws_acm_certificate.main
    ]
  }
}

# Validate the certificate
resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in cloudflare_record.acm_validation : record.hostname]

  timeouts {
    create = "30m"
  }
}