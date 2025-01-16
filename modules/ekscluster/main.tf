#eks module - defines cluster, node-group, add-ons, eks_admin role, data_engineer role

provider "aws" {
	region = var.region
}

resource "aws_eks_cluster" "analytics" {
	name = var.clustername
	role_arn = var.rolearn
	
	vpc_config{
		subnet_ids = var.subnetIDs
		endpoint_public_access = true
		endpoint_private_access = false
	}

	version = var.k8s_version
}

resource "aws_eks_node_group" "analytics_nodes" {

	depends_on = [aws_eks_cluster.analytics]
	
	cluster_name = var.clustername
	node_group_name = var.nodegroupname
	node_role_arn = var.noderolearn
	subnet_ids = var.subnetIDs

	scaling_config {
		desired_size = var.desired_node_count
		max_size = var.max_node_count
		min_size = var.min_node_count
	}

}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.analytics.name
  addon_name   = "vpc-cni"
}