output "dev_vpc_id" {
  value = aws_vpc.dev_vpc.id
}

output "public_dev_subnet_id" {
  description = "Public subnet IDs for dev environment"
  value = {for az, subnet in aws_subnet.public_dev_subnet : az => subnet.id}
}

output "private_dev_subnet_id" {
  description = "Private subnet IDs for dev environment"
  value = {for az, subnet in aws_subnet.private_dev_subnet : az => subnet.id}
}

output "private_eks_subnet_id" {
  description = "Private EKS subnet IDs for dev environment"
  value = {for az, subnet in aws_subnet.private_eks_subnet : az => subnet.id}
}

output "dev_alb_dns_name" {
  description = "DNS name for dev ALB"
  value = aws_lb.dev_alb.dns_name
}

output "dev_nat_gateway_id" {
  description = "ID for dev NAT gateway"
  value = aws_nat_gateway.dev_nat_gateway.id
}