output "certificate" {
  value = module.certs.ekscertificate
  sensitive = true
}

output "certificate_arn" {
  value = module.certs.cert_arn
  sensitive = true
}