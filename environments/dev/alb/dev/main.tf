
module "dev-alb" {
  source   = "../../../../modules/alb/dev"
  cert_arn = data.terraform.remote_state.dev_network.outputs.dev_acm_cert_arn
  alb_sg_id = data.terraform_remote_state.dev_network.outputs.dev_alb_security_group_id
  vpc_id = data.terraform_remote_state.dev_network.outputs.dev_vpc_id 
}