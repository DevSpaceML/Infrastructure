output "region" {
  value = var.region
}

output "eks_vpc_id" {
  value = local.vpc_id
}

output "eks_security_group_id" {
  value = data.aws_security_group.default_sec_group.id
}

output "public_subnet_id_list" {
  value = [for s in aws_subnet.public_subnet_eks : s.id]
}

output "private_subnet_id_list" {
  value = [for s in aws_subnet.private_subnet_eks : s.id]
}
  
output "nodegroup_pvt_subnet_id_list" {
  value = [for s in aws_subnet.nodegroup_private_subnet : s.id]
}

output "rds_private_subnet_id_list" {
  value = [for s in aws_subnet.rds_private_subnet : s.id]
}

output "nat_gateways" {
  value = aws_nat_gateway.eks_nat_gw[*].id
}