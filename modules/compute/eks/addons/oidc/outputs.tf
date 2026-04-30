output "oidc_arn" {
  value = aws_iam_openid_connect_provider.eks_oidc_connect.arn
}

output "aws_iam_role_lb_controller_arn" {
  value = aws_iam_role.lb_controller_role.arn
}

output "k8_svc_acc" {
  value = kubernetes_service_account_v1.svc_acc_lbController.metadata[0].name
}