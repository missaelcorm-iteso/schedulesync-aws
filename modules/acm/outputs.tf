output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.main.arn
}

output "certificate_domain" {
  description = "Domain name of the certificate"
  value       = aws_acm_certificate.main.domain_name
}

output "certificate_validation_arn" {
  description = "ARN of the validated ACM certificate"
  value       = aws_acm_certificate_validation.main.certificate_arn
}