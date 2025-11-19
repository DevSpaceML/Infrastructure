# get data of security group provisioned by EKS cluster

data "aws_security_group" "cluster-sg" {
    vpc_id = var.vpc_id

    tags = {
      "aws:eks:cluster-name" = var.clustername
    }
}

# security group for nodegroup
resource "aws_security_group" "nodegroup-sg" {
    name        = format("eks-%s-nodegroup-sg", var.clustername)
    description = "Security group for EKS nodegroup"
    vpc_id      = var.vpc_id

    tags = {
        Name = format("eks-%s-nodegroup-sg", var.clustername)
    }
}

# allow cluster security group to accept worker node traffic
resource "aws_security_group_rule" "cluster_allow_ingress_from_nodegroup" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_group_id = data.aws_security_group.cluster-sg.id
    source_security_group_id = aws_security_group.nodegroup-sg.id
    description = "Allow cluster to accept incoming worker node traffic"
}

# allow communication between cluster and nodegroup
resource "aws_security_group_rule" "cluster_to_nodegroup" {
    type                     = "ingress"
    from_port                = 443                
    to_port                  = 443
    protocol                 = "tcp"
    security_group_id        = aws_security_group.nodegroup-sg.id
    source_security_group_id = data.aws_security_group.cluster-sg.id
    description = "Allow nodegroup to accept incoming traffic from cluster"
}

# allow nodes to communicate with cluster
resource "aws_security_group_rule" "nodegroup_to_cluster" {
    type                     = "egress"
    from_port                = 443                        
    to_port                  = 443
    protocol                 = "tcp"
    security_group_id        = aws_security_group.nodegroup-sg.id 
    source_security_group_id = data.aws_security_group.cluster-sg.id
    description = "Allow nodes to send traffic to cluster"
}

# allow cluster to communicate with nodes on kubelet port
resource "aws_security_group_rule" "node_ingress_cluster_kubelet" {
   type = "ingress"
   from_port = 10250
   to_port = 10250
   protocol = "tcp"
   security_group_id = aws_security_group.nodegroup-sg.id
   source_security_group_id = data.aws_security_group.cluster-sg.id
} 

# allow nodes to communicate with each other
resource "aws_security_group_rule" "node_to_node" {
    type              = "ingress"
    from_port         = 0
    to_port           = 65535
    protocol          = "udp"
    security_group_id = aws_security_group.nodegroup-sg.id
    source_security_group_id = aws_security_group.nodegroup-sg.id
    description = "Allow nodes to communicate with each other"
}

# cluster to nodes - extended range 
resource "aws_security_group_rule" "cluster_to_node_extended" {
    type                     = "ingress"
    from_port                = 1025                        
    to_port                  = 65535
    protocol                 = "tcp"
    security_group_id        = aws_security_group.nodegroup-sg.id 
    source_security_group_id = data.aws_security_group.cluster-sg.id
    description = "Allow cluster to communicate with nodes ephemeral ports"
}

# allow nodes to reach internet for updates etc
resource "aws_security_group_rule" "node_egress_internet" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    security_group_id = aws_security_group.nodegroup-sg.id
    cidr_blocks      = ["0.0.0.0/0"]
    description = "Allow nodes to reach internet"
}
