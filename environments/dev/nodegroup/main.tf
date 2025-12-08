module "dev_nodes" {
  source                       = "../../../modules/compute/eks/nodegroups"
  node_group_mgr_arn           = data.terraform_remote_state.dev_iam.outputs.node-mgr-arn
  nodegroupname                = "${data.terraform_remote_state.dev_cluster.outputs.clustername}-nodegroup"
  eksclustername               = data.terraform_remote_state.dev_cluster.outputs.clustername
  k8s_version                  = var.k8s_version
  instancetype                 = var.instancetype
  nodegroup_pvt_subnet_id_list = data.terraform_remote_state.dev_network.outputs.nodegroup_subnet_id_list
}