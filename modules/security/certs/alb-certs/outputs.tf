output "dev_acm_cert_validation_options" {
  value = aws_acm_certificate.this.domain_validation_options
}

output "dev_acm_cert_arn" {
  value = aws_acm_certificate.this.arn
}

output "domain_names" {
  value = local.domain_names
}

output "appdomain" {
  value = var.appdomain
}