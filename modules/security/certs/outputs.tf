output "ekscertificate" {
  value = aws_acm_certificate.eks_certificate
}

output "cert_arn" {
  value = aws_acm_certificate.eks_certificate.arn
}
