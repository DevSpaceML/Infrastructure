
output "eks_vpc_id" {
  value = length(aws_vpc.cluster_vpc) > 0 ? aws_vpc.cluster_vpc[0].id : data.aws_vpc.existing_vpc[0].id
}
 
output "cluster_subnet_id_list" {
  value = values(local.pvt_subnets_by_az)

  precondition {
    condition     = length(local.pvt_subnets_by_az) > 0
    error_message = "pvt_subnets_by_az is empty — subnet resources may not have been created."
  }
}

output "rds_private_subnet_id_list" {
  value = values(local.rds_subnets_by_az)
  precondition {
    condition     = length(local.rds_subnets_by_az) > 0
    error_message = "rds_subnets_by_az is empty — subnet resources may not have been created."
  }
}
  
output "nodegroup_pvt_subnet_id_list" {
  value = aws_subnet.nodegroup_private_subnet[*].id

  precondition {
    condition     = length(aws_subnet.nodegroup_private_subnet) > 0
    error_message = "nodegroup_private_subnet is empty — subnet resources may not have been created."
  }
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
  value = data.aws_security_group.default_sec_group.id
}

output "public_subnet_id_list" {
  value = aws_subnet.public_subnet_eks[*].id
}

output "private_subnet_id_list" {
  value = aws_subnet.private_subnet_eks[*].id
}



output "nat_gateways" {
  value = aws_nat_gateway.eks_nat_gw[*].id
}