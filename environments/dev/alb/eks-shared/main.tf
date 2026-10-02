terraform {
  required_providers {
    aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
      }
  }
}

module "eks-shared-alb" {
  source                 = "../../../../modules/alb/dev/eks-alb"
  alb_securitygroup_id   = data.terraform_remote_state.dev_cluster.outputs.alb_sec_group_id
  public_subnet_ids      = data.terraform_remote_state.cluster_network.outputs.public_subnet_id_list
}