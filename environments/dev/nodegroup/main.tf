module "dev_nodes" {
  source             = "../../../modules/compute/eks/nodegroups"
  node_group_mgr_arn = data.terraform_remote_state.dev_iam.outputs.node_group_mgr_arn
  nodegroupname      = local.nodegroup_name
  eksclustername     = data.terraform_remote_state.dev_cluster.outputs.clustername
  k8s_version        = var.k8s_version
  instancetype       = var.instancetype
  nodegroup_pvt_subnet_id_list = data.terraform_remote_state.dev_network.outputs.nodegroup_pvt_subnet_id_list
}