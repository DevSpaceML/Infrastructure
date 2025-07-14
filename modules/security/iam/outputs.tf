output "cluster_role_arn" {
  value = aws_iam_role.eks_cluster_Role.arn
}

output "node_manager_role_arn" {
  value = aws_iam_role.eks_node_manager_role
}
