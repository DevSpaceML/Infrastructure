#eks module - defines cluster, node-group, add-ons, eks_admin role, data_engineer role

data "aws_caller_identity" "current" {}

data "aws_region" "current_region" {}


data "aws_iam_user" "DevOpsAdmin" {
	user_name = "SteveB_devops"
}

data "aws_iam_role" "deployment_role" {
  name = "gha_deploy"
}

data "aws_iam_role" "eks_cluster_Role" {
  name = "eks-cluster-role"
}

resource "aws_eks_cluster" "this" {
	name     = var.clustername
	role_arn = var.cluster_role_arn
	
	vpc_config {
		subnet_ids              = var.public_subnet_ids
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

resource "aws_eks_access_entry" "this" {
  depends_on        = [ aws_eks_cluster.this ]
  for_each          = var.access_entries
  cluster_name      = aws_eks_cluster.this.name
	principal_arn     = each.value.principal_arn
	kubernetes_groups = each.value.type == "STANDARD" ? each.value.kubernetes_groups : null
  user_name         = each.value.type == "STANDARD" ? each.value.user_name : null
  type              = each.value.type

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_eks_access_policy_association" "this" {
  for_each          = {
    for k,v in var.access_entries : k => v
    if v.policy_arn != null  
  }

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_eks_access_entry.this[each.key].principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type = each.value.access_scope_type
    namespaces = each.value.access_scope_type == "namespace" ? each.value.namespaces : null
  }
}

