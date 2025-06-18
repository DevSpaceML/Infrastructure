
output "cluster_name" {
  value = var.name
}

output "eks_vpc_id" {
  value = aws_vpc.cluster_vpc.id
}

output "subnet_id_list" {
  value = data.aws_subnets.eks_subnets.ids
}

output "public_cidr" {
  value = var.public_subnet_cidr_blocks
}

output "private_cidr" {
  value = var.private_subnet_cidr_blocks
}

output "eks_security_group_id" {
  value = aws_vpc.cluster_vpc.default_security_group_id
}

output "public_subnets" {
  value = aws_subnet.public_subnet_eks[*].id
}

output "private_subnets" {
  value = aws_subnet.private_subnet_eks[*].id
}

output "nat_gateways" {
  value = aws_nat_gateway.eks_nat_gw[*].id
}
