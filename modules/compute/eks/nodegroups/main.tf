resource "aws_eks_node_group" "cluster_nodes" {

	cluster_name    = var.eksclustername
	node_group_name = coalesce(var.nodegroupname,format("%s_cluster_nodes", var.eksclustername))
	node_role_arn   = var.node_group_mgr_arn
	subnet_ids      = var.subnet_id_list
	instance_types  = [var.instancetype]
	ami_type 		= "AL2_ARM_64"

	scaling_config {
		desired_size = var.desired_node_count
		max_size     = var.max_node_count
		min_size     = var.min_node_count
	}
}