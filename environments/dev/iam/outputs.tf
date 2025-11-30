output "node_mgr_arn" {
  value = module.iam.node_manager_role_arn
}

output "cluster-role--arn" {
  value = module.iam.cluster_role_arn
}

output "DevOpsAdminSre_arn" {
  value = module.iam.DevOps-SRE-Admin.arn
}

output "techlead_arn" {
  value = module.iam.techlead_developer.arn
}

output "access_entries" {
  value = module.iam.access_entries
}