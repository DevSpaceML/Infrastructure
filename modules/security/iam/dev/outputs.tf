output "devops_role_arn" {
  value = aws_iam_role.devops_admin_role.arn
}

output "deployment_role_arn" {
  value = aws_iam_role.deployment_role.arn
}