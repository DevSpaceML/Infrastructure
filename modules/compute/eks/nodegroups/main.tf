
resource "aws_launch_template" "cluster_nodes_lt" {
  name_prefix = "${var.nodegroupname}-lt-"
  instance_type  = var.instancetype

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"   # enforces IMDSv2
    http_put_response_hop_limit = 2            # allows pod network to reach IMDS
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.nodegroupname}-node"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "cluster_nodes" {
	cluster_name    = var.clustername
	node_group_name = var.nodegroupname
	node_role_arn   = var.node_group_mgr_arn
	subnet_ids      = var.nodegroup_pvt_subnet_id_list
	ami_type        = var.ami_type

	scaling_config {
		desired_size = var.desired_node_count
		max_size     = var.max_node_count
		min_size     = var.min_node_count
	}
    
	launch_template {
		id      = aws_launch_template.cluster_nodes_lt.id
		version = aws_launch_template.cluster_nodes_lt.latest_version
	} 
}