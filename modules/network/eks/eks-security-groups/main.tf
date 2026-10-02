# get data of security group provisioned by EKS cluster

data "aws_security_group" "cluster-sg" {
    vpc_id = var.vpc_id

    tags = {
      "aws:eks:cluster-name" = var.clustername
    }
}

# --- SECURITY GROUPS ---

# ALB
resource "aws_security_group" "alb" {
  name_prefix        = "k8-shared-alb-sg-${var.environment}"
  description        = "alb security group (${var.environment})"
  vpc_id             = var.vpc_id

  tags = { Name = "sg-k8-shared-alb-${var.environment}" }

  lifecycle {
    create_before_destroy = true
  }

}

# NODEGROUP
resource "aws_security_group" "nodegroup-sg" {
    name_prefix        = "nodegroup-sg-${var.clustername}"
    description        = "Security group for EKS nodegroup"
    vpc_id             = var.vpc_id

    tags = {
        Name = "nodegroup-sg-${var.clustername}"
    }
}

# --- SECURITY GROUP RULES ---

# allow internet traffic to reach ALB
 resource "aws_vpc_security_group_ingress_rule" "alb_ingress" {
   from_port                = 80
   to_port                  = 80
   ip_protocol                 = "tcp"
   cidr_ipv4             = ["0.0.0.0/0"]
   security_group_id        = aws_security_group.sg-k8-alb.id
 }

 resource "aws_vpc_security_group_ingress_rule" "alb_http_tls_ingress" {
   from_port         = 443
   to_port           = 443
   ip_protocol          = "tcp"
   cidr_ipv4       = ["0.0.0.0/0"]
   security_group_id = aws_security_group.sg-k8-alb.id
 }

 # Allow alb to reach nodes
 resource "aws_vpc_security_group_egress_rule" "alb_to_nodes" {
   security_group_id            = aws_security_group.alb.id
   ip_protocol                  = "tcp"
   from_port                    = 443
   to_port                      = 443 # double check node ports
   referenced_security_group_id = aws_security_group.nodegroup-sg
 }


# Allow cluster security group to accept worker node traffic
resource "aws_vpc_security_group_ingress_rule" "cluster-sg_allow_ingress_from_nodegroup" {
    from_port         = 443
    to_port           = 443
    ip_protocol       = "tcp"
    security_group_id = data.aws_security_group.cluster-sg.id
    description       = "Allow cluster to accept incoming worker node traffic"
}

resource "aws_vpc_security_group_egress_rule" "cluster_to_nodegroup" {
  from_port                = 1025
  to_port                  = 65535
  ip_protocol              = "tcp"
  security_group_id        = data.aws_security_group.cluster-sg.id
  description              = "Allow cluster to send traffic to nodes on ephemeral ports"
}

resource "aws_vpc_security_group_egress_rule" "cluster_to_nodegroup_kubelet" {
  from_port                = 10250
  to_port                  = 10250
  ip_protocol                 = "tcp"
  security_group_id        = data.aws_security_group.cluster-sg.id
  description              = "Allow cluster to reach kubelet on nodes"
}


# NODEGROUP

# Allow ingress traffic to nodegroup from cluster on kubelet port
resource "aws_vpc_security_group_ingress_rule" "nodegroup-sg_allow_ingress_from_cluster" {
    from_port                = 443                
    to_port                  = 443
    ip_protocol                 = "tcp"
    security_group_id        = aws_security_group.nodegroup-sg.id
    description = "Accept incoming traffic from cluster"
}

# Allow nodes to communicate with cluster
resource "aws_vpc_security_group_ingress_rule" "nodegroup_egress_to_cluster" {
    from_port                = 443                        
    to_port                  = 443
    ip_protocol              = "tcp"
    security_group_id        = aws_security_group.nodegroup-sg.id 
    description              = "Allow nodes to send traffic to cluster"
}

# Allow cluster to communicate with nodes on kubelet port
resource "aws_vpc_security_group_ingress_rule" "cluster_to_nodes" {
   from_port = 10250
   to_port = 10250
   ip_protocol = "tcp"
   security_group_id = aws_security_group.nodegroup-sg.id
} 

# Allow nodes to communicate with each other
resource "aws_vpc_security_group_ingress_rule" "node_to_node" {
    from_port         = 0
    to_port           = 65535
    ip_protocol       = "-1"
    security_group_id = aws_security_group.nodegroup-sg.id
    description       = "Allow nodes to communicate with each other"
}

# Allow cluster to reach nodes - extended range 
resource "aws_vpc_security_group_ingress_rule" "cluster_to_nodes_extended" {
    from_port                = 1025                        
    to_port                  = 65535
    ip_protocol              = "tcp"
    security_group_id        = aws_security_group.nodegroup-sg.id 
    description              = "Allow cluster to communicate with nodes ephemeral ports"
}

# Allow nodes to reach internet for updates etc
resource "aws_vpc_security_group_egress_rule" "nodes_to_internet" {
    from_port         = 0
    to_port           = 0
    ip_protocol          = "-1"
    security_group_id = aws_security_group.nodegroup-sg.id
    description = "Allow nodes to reach internet"
}
