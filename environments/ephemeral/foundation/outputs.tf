output "k8_svc_acc" {
    value  = module.k8_auth.k8_svc_acc
}

output "ctrlr_role_arn" {
    value  = module.oidc.aws_iam_role_lb_controller_arn
}