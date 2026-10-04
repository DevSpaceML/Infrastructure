output alb_name {
    value = module.eks-shared-alb.alb_name
}

output "acm_cert_arn" {
  value = module.alb-certs.acm_cert_arn
}