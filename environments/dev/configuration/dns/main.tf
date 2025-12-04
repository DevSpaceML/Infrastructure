module "route53" {
  source             = "../../../../modules/dns/route53"
  private_cidr_block = data.terraform_remote_state.dev_network.outputs.private_cidr
  public_cidr_block  = data.terraform_remote_state.dev_network.outputs.public_cidr
  securitygroupId    = data.terraform_remote_state.dev_network.outputs.eks_security_group_id
  ekscertificate     = data.terraform_remote_state.certs.outputs.certificate
  certarn            = data.terraform_remote_state.certs.outputs.certificate_arn
}