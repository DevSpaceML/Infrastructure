output "certificate" {
  value = module.certs.eks_certificate
}

output "certificate_arn" {
  value = module.certs.cert_arn
}