# modules/dns/main.tf
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
}

# Main domain record
resource "cloudflare_record" "main" {
  zone_id = var.cloudflare_zone_id
  name    = "schedulesync-${var.environment}" # This will create schedulesync-dev.domain.com
  value   = var.alb_dns_name
  type    = "CNAME"
  proxied = var.enable_proxy
  ttl     = 1 # Auto when proxied
}

# API subdomain record (optional if using path-based routing)
resource "cloudflare_record" "api" {
  zone_id = var.cloudflare_zone_id
  name    = "api.schedulesync-${var.environment}" # This will create api.schedulesync-dev.yourdomain.com
  value   = var.alb_dns_name
  type    = "CNAME"
  proxied = var.enable_proxy
  ttl     = 1
}

# Cloudflare SSL/TLS Settings (optional)
resource "cloudflare_zone_settings_override" "main" {
  zone_id = var.cloudflare_zone_id

  settings {
    ssl = "strict"
    min_tls_version = "1.2"
    tls_1_3 = "on"
    automatic_https_rewrites = "on"
    always_use_https = "on"
  }
}