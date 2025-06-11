output "EKS_Cluster_Role_Arn" {
  value = aws_iam_role.EKS_Cluster_Role.arn
}

output "Node_Manager_Role_Arn" {
  value = aws_iam_role.EKS_Node_Manager_Role.arn
}
