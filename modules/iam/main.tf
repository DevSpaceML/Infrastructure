# IAM resources and policies
# IAM Role for the EKS Control Plane, must have AmazonEKSClusterPolicy
# IAM Role for worker Nodes. Policies - AmazonEKSWorkerNodePolicy, AmazonEC2ContainerRegistryReadOnly, AmazonEKS_CNI_Policy
# IAM Role for Kubernetes Service Accounts (IRSA)
# --------------------------

data "aws_eks_cluster" "eks-cluster" {
	name = var.eksclustername
}

data "aws_eks_cluster_auth" "cluster_auth" {
	name = var.eksclustername
}

data "tls_certificate" "eks_oidc_cert" {
	url = data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}


resource "aws_iam_openid_connect_provider" "eks_oidc_connect" {
	client_id_list  = ["sts.amazonaws.com"]
	thumbprint_list = [data.tls_certificate.eks_oidc_cert.certificates[0].sha1_fingerprint]
	url             = data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer	
}

resource "aws_iam_role" "service_account_role" {
	name = "eks_service_account_role"

	assume_role_policy = jsonencode({
	  Version = "2012-10-17"
	  Statement = [{
	  	Effect = "Allow"
	  	Principal = {
	  		Federated = aws_iam_openid_connect_provider.eks_oidc_connect.arn
	  	}
	  	Action = "sts:AssumeRoleWithWebIdentity"
	  	Condition = {
        StringEquals = {
          "${replace(data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:eksanalytics:aws_iam_openid_connect_provider.eks_oidc_connect.arn"
        }
      }
    }]
  })
}

resource "aws_iam_role" "cluster_role" {
	name = "ekscontrol"

	assume_role_policy = jsonencode({
		Version   = "2012-10-17"
		Statement = [{
		  Effect = "Allow"
		  Principal = {
		    Service = "eks.amazonaws.com"
		  }
		  Action = "sts:AssumeRole"		
		}] 
	   }
	)	
}

resource "aws_iam_role_policy_attachment" "cluster_role_policy" {
	role = aws_iam_role.cluster_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# node manager role and policy

resource "aws_iam_role" "node_manager_role" {
	name = "node_mgr_role"

	assume_role_policy = jsonencode({
		Version = "2012-10-17"
		Statement = [{
		  Effect  = "Allow"
		  Principal = {
		    Service = "ec2.amazonaws.com"
		  }
		  Action = "sts:AssumeRole"	
		}]
	})
}

resource "aws_iam_role_policy_attachment" "node_manager_policy" {
	role       = aws_iam_role.node_manager_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
	role       = aws_iam_role.node_manager_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_read_only_policy" {
	role       = aws_iam_role.node_manager_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}