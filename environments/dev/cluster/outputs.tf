output "cluster_endpoint" {
  value = module.dev_cluster.cluster_endpoint
}

output "cluster_cert" {
  value = module.dev_cluster.cluster_certificate
}
output "cluster_name" {
  value = module.dev_cluster.cluster_name
}

output "domain_name" {
  value = module.hosted_zone.domain_name
}

output "projectname" {
  value = var.projectname
}

output "environment" {
  value = var.environment
}