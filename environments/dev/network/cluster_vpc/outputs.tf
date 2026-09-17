output "vpc_id" {
  value = module.cluster_vpc.eks_vpc_id
}

output "region" {
  value = module.cluster_vpc.region
}

# -- Subnet ID lists for cluster and nodegroups

output "public_subnet_id_list" {
  value = module.cluster_vpc.public_subnet_id_list
}

output "private_subnet_id_list" {
  value = module.cluster_vpc.private_subnet_id_list
}

output "nodegroup_subnet_id_list" {
  value = module.cluster_vpc.nodegroup_pvt_subnet_id_list
}

output "db_subnet_id_list" {
  value = module.cluster_vpc.rds_private_subnet_id_list
}

# --

output "nat_gateway_id_list" {
  value = module.cluster_vpc.nat_gateways
}

output "eks_sec_group_id" {
  value = module.cluster_vpc.eks_security_group_id
}
