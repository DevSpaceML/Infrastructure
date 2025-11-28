module "dev_nodes" {
  source             = "../../../modules/compute/eks/nodegroups"
  node_group_mgr_arn = module.iam.node_manager_role_arn
  nodegroupname      = local.nodegroup_name
  eksclustername     = module.dev_cluster.cluster_name
  nodegroup_pvt_subnet_id_list = module.dev_vpc.nodegroup_pvt_subnet_id_list
}