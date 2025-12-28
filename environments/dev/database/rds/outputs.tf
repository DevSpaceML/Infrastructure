output "db_endpoint" {
  value = module.rds_appdata.db_instance_endpoint
}

output "db_instance_identifier" {
  value = module.rds_appdata.db_instance_identifier
}