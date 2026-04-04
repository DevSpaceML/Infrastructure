provider "kubernetes" {
   host = module.dev_cluster.cluster_endpoint
   cluster_ca_certificate = module.dev_cluster.cluster_certificate
   
   exec {
	 api_version = "client.authentication.k8s.io/v1beta1"
	 command = "aws"
	 args = [
      "eks", "get-token",
      "--cluster-name", module.dev_cluster.cluster_name,
      "--region",       var.region
    ]
   }
}

module "Dev_k8_auth" {
  source           = "../../../../modules/security/auth"
  clustername      = data.terraform_remote_state.dev_cluster.outputs.cluster_name
  cluster_cert     = data.terraform_remote_state.dev_cluster.outputs.cluster_cert
  noderolearn      = data.terraform_remote_state.dev_iam.outputs.node-mgr-arn
  clusteradminrole = data.terraform_remote_state.dev_iam.outputs.cluster-role-arn
  DevOpsAdminSre   = data.terraform_remote_state.dev_iam.outputs.DevOpsAdminSre-arn
  techlead         = data.terraform_remote_state.dev_iam.outputs.techlead-arn
  hosturl          = data.terraform_remote_state.dev_cluster.outputs.cluster_endpoint
  region           = data.terraform_remote_state.dev_vpc.outputs.region
}