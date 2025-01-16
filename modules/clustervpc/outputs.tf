
output "eks_vpc_id" {
  value = aws_vpc.cluster_vpc.id
}

output "subnet_id_list" {
  value = data.aws_subnets.eks_subnets.ids
}

output "eks_security_group_id" {
  value = aws_vpc.cluster_vpc.default_security_group_id
}
