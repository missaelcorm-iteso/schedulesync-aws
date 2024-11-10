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
  app_domain = "${var.project}-${var.environment}"
}

# Main domain record
resource "cloudflare_record" "main" {
  zone_id         = var.cloudflare_zone_id
  name            = local.app_domain # This will create schedulesync-dev.domain.com
  content         = var.alb_dns_name
  type            = "CNAME"
  proxied         = var.enable_proxy
  allow_overwrite = true
  ttl             = 1 # Auto when proxied
}

# API subdomain record (optional if using path-based routing)
resource "cloudflare_record" "api" {
  zone_id         = var.cloudflare_zone_id
  name            = "api-${local.app_domain}" # This will create *.schedulesync-dev.yourdomain.com
  content         = var.alb_dns_name
  type            = "CNAME"
  proxied         = var.enable_proxy
  allow_overwrite = true
  ttl             = 1
}

# Cloudflare SSL/TLS Settings (optional)
resource "cloudflare_zone_settings_override" "main" {
  zone_id = var.cloudflare_zone_id

  settings {
    ssl              = "strict"
    always_use_https = "on"
  }
}