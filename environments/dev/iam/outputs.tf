output "node-mgr-arn" {
  value = module.iam.node_manager_role_arn
}

output "cluster-role-arn" {
  value = module.iam.cluster_role_arn
}

output "DevOpsAdminSre-arn" {
  value = module.iam.DevOps-SRE-Admin.arn
}

output "techlead-arn" {
  value = module.iam.techlead_developer_arn
}

output "access-entries-map" {
  value = module.iam.access_entries
}

output "github-actions-arn" {
  value = module.iam.github_actions_role_arn
}

