/*
output "alb_arn" {
  value = data.aws_lb.eks-lb.arn
}

output "alb_dns_name" {
  value = data.aws_lb.eks-lb.dns_name
}

output "alb_zone_id" {
  value = data.aws_lb.eks-lb.zone_id
}

output "alb_security_groups" {
  value = data.aws_lb.eks-lb.security_groups
}

output "alb_target_group_arns" {
  value = data.aws_lb.eks-lb.arn
}

output "svc_acc_name" {
  value = kubernetes_service_account.svc_acc_lbController.metadata[0].name
}

*/