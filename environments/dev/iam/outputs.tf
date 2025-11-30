output "node-mgr--arn" {
  value = module.iam.node_manager_role_arn
}

output "cluster-role--arn" {
  value = module.iam.cluster_role_arn
}

output "DevOpsAdminSre--arn" {
  value = module.iam.DevOps-SRE-Admin.arn
}

output "techlead--arn" {
  value = module.iam.techlead_developer.arn
}

output "access-entries-map" {
  value = module.iam.access_entries
}