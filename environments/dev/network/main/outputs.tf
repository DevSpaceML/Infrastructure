output "dev_vpc_id" {
  value = module.dev_network.dev_vpc_id
}

/** Public subnet IDs */

output "public_subnet_id_list" {
  description = "Public subnet IDs for dev environment"
  value = module.dev_network.public_subnet_id_list
}

output "private_subnet_id_list" {
  description = "Private subnet IDs for dev environment"
  value = module.dev_network.private_subnet_id_list
}

output "private_ecs_subnet_id_list" {
  description = "Private ECS subnet IDs for dev environment"
  value = module.dev_network.private_ecs_subnet_id_list
}

/* Security group IDs */

output "ecs_security_group_id" {
  description = "Security group ID for dev ECS"
  value = module.dev_network.ecs_security_group_id 
}

output "alb_security_group_id" {
  description = "Security group ID for dev ALB"
  value = module.dev_network.alb_security_group_id
}

output "dev_nat_gateway_id" {
  description = "ID for dev NAT gateway"
  value = module.dev_network.dev_nat_gateway_id
}
