output "DevOps-SRE-Admin" {
  value = data.aws_iam_user.DevOpsAdmin
}

output "techlead_developer_arn" {
  value = aws_iam_user.developer.arn
}

output "cluster_role_arn" {
  value = aws_iam_role.eks_cluster_Role.arn
}

output "node_manager_role_arn" {
  value = aws_iam_role.eks_node_manager_role.arn
}

output "github_actions_role_arn" {
  value = data.aws_iam_role.github_actions_role.arn
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
    
    techlead = {
      principal_arn = aws_iam_user.developer.arn
      type = "STANDARD"
      kubernetes_groups = ["view"]
    } 
  }
}
