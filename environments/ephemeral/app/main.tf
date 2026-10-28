# App Deployment - Application-specific resources and configurations


locals {
  cluster = data.terraform_remote_state.cluster.outputs
}

module "app" {
  source = "../../modules/app"
  cluster_id = local.cluster.cluster_id
}