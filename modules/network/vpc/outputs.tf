
output "eks_vpc_id" {
  value = aws_vpc.cluster_vpc.id
}

output "subnet_id_list" {
  value = local.cluster_subnet_ids
}

output "public_cidr" {
  value = var.public_subnet_cidr_blocks
}

output "private_cidr" {
  value = var.private_subnet_cidr_blocks
}

output "nodegroup_pvt_cidr" {
  value = var.nodegroup_pvt_subnet_cidr_blocks
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

output "nodegroup_pvt_subnet_id_list" {
  value = aws_subnet.nodegroup_private_subnet[*].id
}

output "rds_private_subnet_list" {
  value = local.rds_subnets_by_id
}

output "nat_gateways" {
  value = aws_nat_gateway.eks_nat_gw[*].id
}