terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "ecs_fargate" {
  source = "../../../../modules/compute/fargate"
  aws_region = var.region
  ecs_security_group_id = data.terraform_remote_state.dev_network.outputs.ecs_security_group_id
  private_ecs_subnet_ids = data.terraform_remote_state.dev_network.outputs.private_ecs_subnet_id_list
  target_group_arn = data.terraform_remote_state.dev_alb.outputs.ecs_slfsvc_tg_arn
}