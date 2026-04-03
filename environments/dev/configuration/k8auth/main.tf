module "Dev_k8_auth" {
  source = "../../../../modules/security/auth"
  clustername      = data.terraform_remote_state.dev_cluster.outputs.cluster_name
  noderolearn      = data.terraform_remote_state.dev_iam.outputs.node-mgr-arn
  clusteradminrole = data.terraform_remote_state.dev_iam.outputs.cluster-role-arn
  DevOpsAdminSre   = data.terraform_remote_state.dev_iam.outputs.DevOpsAdminSre-arn
  techlead         = data.terraform_remote_state.dev_iam.outputs.techlead-arn
  hosturl          = data.terraform_remote_state.dev_cluster.outputs.cluster_endpoint
  cluster_cert     = data.terraform_remote_state.dev_cluster.outputs.cluster_cert
}