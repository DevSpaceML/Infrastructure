output "k8_svc_acc" {
    value  = module.oidc_auth.k8_svc_acc
}

output "ctrlr_role_arn" {
    value  = module.oidc_auth.aws_iam_role_lb_controller_arn
}