output "domain_name" {
  description = "Main domain name"
  value       = cloudflare_record.main.hostname
}

output "api_domain_name" {
  description = "API domain name"
  value       = cloudflare_record.api.hostname
}