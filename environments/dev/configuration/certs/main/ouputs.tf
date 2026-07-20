output "dev_acm_cert_arn" {
  value = module.dev_certs.dev_acm_cert_arn
}

output "dev_acm_cert_validation_options" {
  value = module.dev_certs.dev_acm_cert_validation_options
}

output "domain_names" {
  value = module.dev_certs.domain_names
}

output "appdomain" {
  value = module.dev_certs.appdomain
}