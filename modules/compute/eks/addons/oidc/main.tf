data "aws_eks_cluster" "eks-cluster" {
  name = var.clustername
}

resource "aws_iam_openid_connect_provider" "eks_oidc_connect" {
  client_id_list = [ "sts.amazonaws.com" ]
  url = data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

data "aws_iam_openid_connect_provider" "eks_oidc" {
  depends_on = [ aws_iam_openid_connect_provider.eks_oidc_connect ]
  url        = data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "lb_controller_role"{
    depends_on = [ aws_iam_openid_connect_provider.eks_oidc_connect ]
    name = "lbControllerRole"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow"
            Principal = {
                Federated = aws_iam_openid_connect_provider.eks_oidc_connect.arn
            }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = {
                StringEquals = {
                    "${replace(data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:svcacc-lbc"
                    "${replace(data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
                }
            }
       }]
    })  
}

# IRSA for vpc-cni addon
resource "aws_iam_role" "irsa_vpc_cni" {
    depends_on = [ aws_iam_openid_connect_provider.eks_oidc_connect ]
    name = "${var.clustername}-vpc-cni-irsa"
    assume_role_policy = file("${path.module}/vpcCniAssumeRolePolicy.json")
}

resource "aws_iam_role_policy_attachment" "attach_vpc_cni_irsa_policy" {
    role       = aws_iam_role.irsa_vpc_cni.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# kubernetes service account for lbControllerRole
resource "kubernetes_service_account_v1" "svc_acc_lbController" {
  metadata {
    name        = "svcacc-lbc"
    namespace   = "kube-system"
    annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.lb_controller_role.arn
    }
  }
}

resource "aws_iam_policy" "lb_controller_policy" {
    name        = "lbControllerPolicy"
    description = "IAM policy for lbControllerRole"
    policy      = file("${path.module}/lbControllerPolicy.json")  
}

resource "aws_iam_role_policy_attachment" "attach_lbControllerPolicy" {
  role       = aws_iam_role.lb_controller_role.name
  policy_arn = aws_iam_policy.lb_controller_policy.arn
}