terraform {
  required_providers {
    aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
      }
  }
}

module "eks-shared-alb" {
  source                 = "../../../../modules/alb/eks-alb"
  alb_sg_id              = data.terraform_remote_state.cluster_network.outputs.eks_sec_group_id
  vpc_id                 = data.terraform_remote_state.cluster_network.outputs.vpc_id
  public_dev_subnet_list = data.terraform_remote_state.cluster_network.outputs.public_subnet_id_list
}