terraform {
  required_providers {
    aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
      }
  }
}

module "ephmrl_routing" {
  source = "../../../../modules/alb/dev/eks"
  alb_arn = data.terraform_remote_state.dev_alb.outputs.dev_alb_arn
  vpc_id  = data.terraform_remote_state.dev_network.outputs.dev_vpc_id
  projectname = data.terraform_remote_state.dev_cluster.outputs.projectname
}