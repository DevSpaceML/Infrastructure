
module "irsa_ebs_csi"{
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = var.cluster_name
  addon_name   = "aws-ebs-csi-driver"
  service_account_role_arn = 
}