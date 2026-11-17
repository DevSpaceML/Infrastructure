module "irsa_ebs_csi"{
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.8.1"
  name = join("-", [substr(var.cluster_name, 0, 10), "ebscsi-irsa"])
  attach_ebs_csi_policy = true
  
  oidc_providers = {
    main = {
        provider_arn = var.oidc_arn
        namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  } 
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = var.cluster_name
  addon_name   = "aws-ebs-csi-driver"
  service_account_role_arn = module.irsa_ebs_csi.arn
}