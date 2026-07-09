output "dev_vpc_id" {
  value = aws_vpc.dev_vpc.id
}

/** Public subnet IDs */
output "public_subnet_id_list" {
  description = "Public subnet IDs for dev environment"
  value = [for subnet in aws_subnet.public_dev_subnet : subnet.id]
}

output "private_subnet_id_list" {
  description = "Private subnet IDs for dev environment"
  value = [for subnet in aws_subnet.private_dev_subnet : subnet.id]
}

output "private_ecs_subnet_id_list" {
  description = "Private ECS subnet IDs for dev environment"
  value = [for subnet in aws_subnet.private_ecs_subnet : subnet.id]
}

/* Security group IDs */
output "ecs_security_group_id" {
  description = "Security group ID for dev ECS"
  value = aws_security_group.ecs_sg.id
}

output "alb_security_group_id" {
  description = "Security group ID for dev ALB"
  value = aws_security_group.alb_sg.id
}


output "dev_nat_gateway_id" {
  description = "ID for dev NAT gateway"
  value = aws_nat_gateway.dev_nat_gateway.id
}