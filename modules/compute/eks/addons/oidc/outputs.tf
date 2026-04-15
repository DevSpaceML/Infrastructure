output "oidc_arn" {
  value = aws_iam_openid_connect_provider.eks_oidc_connect.arn
}