#eks module - defines cluster, node-group, add-ons, eks_admin role, data_engineer role

data "aws_caller_identity" "current" {}

data "aws_region" "current_region" {}


data "aws_iam_user" "DevOpsAdmin" {
	user_name = "DevOpsAdmin"
}

data "aws_iam_role" "eks_cluster_Role" {
  name = "eks-cluster-role"
}

resource "aws_eks_cluster" "this" {
	name     = var.clustername
	role_arn = var.cluster_role_arn
	
	vpc_config {
		subnet_ids              = var.subnetIdlist
		endpoint_public_access  = var.endpoint_public_access
		endpoint_private_access = var.endpoint_private_access
    security_group_ids      = var.additional_security_group_ids
	}

	access_config {
    authentication_mode = var.authentication_mode
  }
	
	enabled_cluster_log_types = var.enabled_cluster_log_types
	version                   = var.k8s_version

  dynamic "encryption_config" {
    for_each = var.cluster_encryption_config
    content {
      provider {
        key_arn = encryption_config.value.provider_key_arn
      }
      resources = encryption_config.value.resources
    }
  }

	tags = {
		Environment = var.environment
	}

}

resource "aws_eks_access_entry" "eks_access" {
  depends_on = [ aws_eks_cluster.this ]

  for_each          = var.access_entries
  cluster_name      = aws_eks_cluster.this.name
	principal_arn     = each.value.principal_arn
	kubernetes_groups = each.value.kubernetes_groups
	type              = each.value.type
  user_name         = try(each.value.user_name, null)

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_eks_access_policy_association" "eks_cluster_admin_policy" {
  depends_on    = [ aws_eks_access_entry.eks_access ]
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = data.aws_iam_role.eks_cluster_Role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

}

resource "aws_eks_access_policy_association" "eks_eks_admin_policy" {
  depends_on    = [ aws_eks_access_entry.eks_access ]
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = data.aws_iam_user.DevOpsAdmin.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"

  access_scope {
    type = "cluster"
  }

}