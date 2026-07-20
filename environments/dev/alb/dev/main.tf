/* Dev ALB. Can be created here or in network deployment */
terraform {
  required_providers {
    aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
      }
  }
}

module "dev-alb" {
  source      = "../../../../modules/alb/dev"
  cert_arn    = data.terraform_remote_state.dev_certs.outputs.dev_acm_cert_arn
  alb_sg_id   = data.terraform_remote_state.dev_network.outputs.alb_security_group_id
  vpc_id      = data.terraform_remote_state.dev_network.outputs.dev_vpc_id
  domain_name = data.terraform_remote_state.dev_certs.outputs.appdomain
  public_dev_subnet_list = data.terraform_remote_state.dev_network.outputs.public_subnet_id_list
}