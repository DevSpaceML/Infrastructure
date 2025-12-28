
module "certs" {
  source             = "../../../../modules/security/certs"
  security-groups    = data.terraform_remote_state.dev_network.outputs.security_group_ids
  private_cidr_block = data.terraform_remote_state.dev_network.outputs.private_cidr
  public_cidr_block  = data.terraform_remote_state.dev_network.outputs.public_cidr
  eks_subnets        = data.terraform_remote_state.dev_network.outputs.cluster_subnet_id_list
  securitygroupId    = data.terraform_remote_state.dev_network.outputs.eks_sec_group_id
  cluster_vpc_id     = data.terraform_remote_state.dev_network.outputs.vpc_id
  eksclustername     = data.terraform_remote_state.dev_cluster.outputs.cluster_name
}