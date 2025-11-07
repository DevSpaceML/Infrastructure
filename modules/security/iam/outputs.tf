output "cluster_role_arn" {
  value = aws_iam_role.eks_cluster_Role.arn
}

output "node_manager_role_arn" {
  value = aws_iam_role.eks_node_manager_role
}

output "access_entries" {
  description = "Map of access entries to create"
  value = {
    devops_admin = {
      principal_arn = data.aws_iam_user.DevOpsAdmin.arn
      type = "STANDARD"
      kubernetes_groups = ["cluster-admin"]
    }
    
    cluster_admin = {
      principal_arn = aws_iam_role.eks_cluster_Role.arn
      type = "STANDARD"
      kubernetes_groups = ["cluster-admin"]
    }

    node_manager = {
      principal_arn = aws_iam_role.eks_node_manager_role.arn
      type = "STANDARD"
      kubernetes_groups = ["devops"]
    }

    techlead = {
      principal_arn = aws_iam_user.developer.arn
      type = "STANDARD"
      kubernetes_groups = ["view"]
    } 
  }
}
