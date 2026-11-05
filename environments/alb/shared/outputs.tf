output "alb_name" {
  value = module.shared-k8-alb.alb_name
}

output "alb_dns_name" {
  value = module.shared-k8-alb.alb_dns_name
}

output "alb_arn" {
  value = module.shared-k8-alb.alb_arn
}

output "alb_securitygroup_id" {
  value = module.shared-k8-alb.alb_securitygroup_id
}

output "acm_cert_arn" {
  value = module.alb-certs.acm_cert_arn
}