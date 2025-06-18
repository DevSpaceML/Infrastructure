#eks module - defines cluster, node-group, add-ons, eks_admin role, data_engineer role

data "aws_caller_identity" "current" {}

data "aws_region" "current_region" {}

data "aws_iam_role" "clusteradminrole" {
  name = "ClusterAdminRole"
}

resource "aws_eks_cluster" "ekscluster" {
	name     = var.clustername
	role_arn = var.EksClusterRole-arn
	
	vpc_config {
		subnet_ids              = var.public_subnet_ids
		endpoint_public_access  = true
		endpoint_private_access = true
	}

	access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  
  }
	
	enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
	version = var.k8s_version

	tags = {
		Environment = var.environment
	}
}

# Update Kube Config
resource "null_resource" "update_kubeconfig" {
  depends_on = [ aws_eks_cluster.ekscluster ]

  provisioner "local-exec" {
    command = <<EOT
    set -euo pipefail
    set -v
	  echo "Updating Kube config..."
    
    aws eks update-kubeconfig --region ${var.region} --name ${var.clustername} --profile DevOpsAdmin
	  echo "current context is :>>"
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "aws_eks_access_entry" "eks_admin_access" {
	depends_on = [ aws_eks_cluster.ekscluster ]

	cluster_name      = aws_eks_cluster.ekscluster.name
	principal_arn     = "arn:aws:iam::312907937200:user/devopsadmin"
	kubernetes_groups = ["eks-admins"]
	type              = "STANDARD"
}

resource "aws_eks_access_entry" "role_admin_access" {
	depends_on = [ aws_eks_cluster.ekscluster ]

	cluster_name      = aws_eks_cluster.ekscluster.name
	principal_arn     = "arn:aws:iam::312907937200:role/ClusterAdminRole"
	kubernetes_groups = ["eks-admins"]
	type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks_cluster_admin_policy" {
  depends_on = [ aws_eks_access_entry.eks_admin_access ]
  cluster_name = aws_eks_cluster.ekscluster.name
  principal_arn = "arn:aws:iam::312907937200:role/ClusterAdminRole"
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

}

resource "aws_eks_access_policy_association" "eks_eks_admin_policy" {
  depends_on = [ aws_eks_access_entry.eks_admin_access ]
  cluster_name = aws_eks_cluster.ekscluster.name
  principal_arn = "arn:aws:iam::312907937200:role/ClusterAdminRole"
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"

  access_scope {
    type = "cluster"
  }

}