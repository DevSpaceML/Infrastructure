output "cluster_role_arn" {
  value = aws_iam_role.eks_cluster_Role.arn
}

output "node_manager_role_arn" {
  value = aws_iam_role.eks_node_manager_role
}


output "access_entries" {
  description = "Map of access entries to create"
  value = {
    cluster_admin = {
      principal_arn = aws_iam_role.eks_cluster_Role.arn
      type = "STANDARD"
    }

    node_manager = {
      principal_arn = aws_iam_role.eks_node_manager_role.arn
      type = "STANDARD"
    }

    techlead = {
      principal_arn = aws_iam_user.developer.arn
      type = "STANDARD"
    } 
  }
}
