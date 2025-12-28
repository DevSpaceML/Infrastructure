output "certificate" {
  value = module.certs.ekscertificate
}

output "certificate_arn" {
  value = module.certs.cert_arn
}