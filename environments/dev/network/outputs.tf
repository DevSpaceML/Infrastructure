output "vpc_id" {
  value = module.dev_vpc.eks_vpc_id
}

output "public_cidr" {
  value = module.dev_vpc.public_cidr
}

output "private_cidr" {
  value = module.dev_vpc.private_cidr
}

output "nodegroup_cidr" {
  value = module.dev_vpc.nodegroup_pvt_cidr
}

# --

output "cluster_subnet_id_list" {
  value = module.dev_vpc.subnet_id_list
}

output "public_subnet_id_list" {
  value = module.dev_vpc.public_subnets
}

output "private_subnet_id_list" {
  value = module.dev_vpc.private_subnets
}

output "nodegroup_subnet_id_list" {
  value = module.dev_vpc.nodegroup_pvt_subnet_id_list
}

output "db_subnet_id_list" {
  value = module.dev_vpc.rds_private_subnet_list
}

# --

output "nat_gateway_id_list" {
  value = module.dev_vpc.nat_gateways
}

output "eks_sec_group_id" {
  value = module.dev_vpc.eks_security_group_id
}