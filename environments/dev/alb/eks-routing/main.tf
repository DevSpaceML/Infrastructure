terraform {
  required_providers {
    aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
      }
  }
}

module "ephmrl_routing" {
  source      = "../../../../modules/alb/dev/eks"
  alb_arn     = data.terraform_remote_state.eks_alb.outputs.alb_arn
  vpc_id      = data.terraform_remote_state.cluster_network.outputs.vpc_id
  projectname = data.terraform_remote_state.dev_cluster.outputs.projectname
  clustername = data.terraform_remote_state.dev_cluster.outputs.cluster_name
  alb_securitygroup_id = data.terraform_remote_state.dev_network.outputs.eks_sec_group_id
}