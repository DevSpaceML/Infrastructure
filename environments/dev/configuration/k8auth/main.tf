module "Dev_k8_auth" {
  source = "../../../../modules/security/auth"
  eksclustername   = data.terraform_remote_state.dev_cluster.outputs.cluster_name
  noderolearn      = data.terraform_remote_state.dev_iam.outputs.node-manager-role
  clusteradminrole = data.terraform_remote_state.dev_iam.outputs.cluster-role-arn
  DevOpsAdminSre   = data.terraform_remote_state.dev_iam.outputs.DevOps-SRE-Admin
  techlead         = data.terraform_remote_state.dev_iam.outputs.techlead_developer
  hosturl          = data.terraform_remote_state.dev_cluster.outputs.cluster_endpoint 
}