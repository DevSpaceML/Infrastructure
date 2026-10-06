# Data AWS provisioned cluster security group
data "aws_eks_cluster" "this" {
    name = var.clustername
}

locals {
  cluster_sg_id = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

#     --- SECURITY GROUPS ---     #

resource "aws_security_group" "alb-sg" {
  name_prefix        = "k8-shared-alb-sg-${var.environment}"
  description        = "ALB security group (${var.environment})"
  vpc_id             = var.vpc_id

  tags = { Name = "sg-k8-shared-alb-${var.environment}" }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "nodegroup-sg" {
    name_prefix        = "nodegroup-${var.clustername}"
    description        = "Security group for EKS nodegroup"
    vpc_id             = var.vpc_id

    tags = {
        Name = "nodegroup-sg-${var.clustername}"
    }

    lifecycle {
    create_before_destroy = true
  }
}

# --- ALB RULES --- #

# * ALB Ingress * 
# Allow internet traffic to reach ALB
 resource "aws_vpc_security_group_ingress_rule" "alb_http" {
   security_group_id        = aws_security_group.alb-sg.id
   from_port                = 80
   to_port                  = 80
   ip_protocol              = "tcp"
   cidr_ipv4                = "0.0.0.0/0"
 }

# Allow ALB to accept tls internet traffic
 resource "aws_vpc_security_group_ingress_rule" "alb_https" {
   security_group_id = aws_security_group.alb-sg.id
   from_port         = 443
   to_port           = 443
   ip_protocol       = "tcp"
   cidr_ipv4         = "0.0.0.0/0"
 }

 # * ALB Egress * 
 # Allow ALB to send traffic to nodes
 resource "aws_vpc_security_group_egress_rule" "alb_to_nodes" {
   security_group_id            = aws_security_group.alb-sg.id
   ip_protocol                  = "tcp"
   from_port                    = 8000
   to_port                      = 8000 
   referenced_security_group_id = aws_security_group.nodegroup-sg.id
 }

# * Cluster (Control Plane) Ingress *
# Allow cluster to accept incoming worker node traffic
resource "aws_vpc_security_group_ingress_rule" "cluster_ingress_from_nodegroup" {
    security_group_id            = local.cluster_sg_id
    from_port                    = 443
    to_port                      = 443
    ip_protocol                  = "tcp"
    description                  = "Allow cluster to accept incoming worker node traffic"
    referenced_security_group_id = aws_security_group.nodegroup-sg.id
}

# * Nodegroup Ingress *

# Allow ALB traffic into nodegroup
resource "aws_vpc_security_group_ingress_rule" "nodes_from_alb" {
    security_group_id            = aws_security_group.nodegroup-sg.id
    from_port                    = 8000
    to_port                      = 8000
    ip_protocol                  = "tcp"
    referenced_security_group_id = aws_security_group.alb-sg.id
    description                  = "Allow incoming alb traffic"
}

# Allow tls traffic into nodegroup from cluster
resource "aws_vpc_security_group_ingress_rule" "nodes_from_cluster" {
    security_group_id            = aws_security_group.nodegroup-sg.id
    from_port                    = 443                
    to_port                      = 443
    ip_protocol                  = "tcp"
    referenced_security_group_id = local.cluster_sg_id
    description                  = "Allow incoming cluster traffic"
}

# Allow traffic into nodes from cluster on extended range of ports
resource "aws_vpc_security_group_ingress_rule" "node_kubelet_from_cluster" {
    security_group_id            = aws_security_group.nodegroup-sg.id 
    from_port                    = 1025                        
    to_port                      = 65535
    ip_protocol                  = "tcp"
    referenced_security_group_id = local.cluster_sg_id
    description                  = "Allow incoming control plane traffic to nodegroup kubelet(10250) and webhook ports"
}

# Allow nodes to communicate with each other
resource "aws_vpc_security_group_ingress_rule" "node_to_node" {
    security_group_id            = aws_security_group.nodegroup-sg.id
    ip_protocol                  = "-1"
    referenced_security_group_id = aws_security_group.nodegroup-sg.id
    description                  = "Allow all incoming nodes to node traffic"
}

# * Nodegroup Egress *
# Allow all outgoing node traffic
resource "aws_vpc_security_group_egress_rule" "nodes_to_internet" {
    security_group_id = aws_security_group.nodegroup-sg.id
    ip_protocol       = "-1"
    cidr_ipv4         = "0.0.0.0/0"
    description       = "Allow all outbound traffic from nodes"
}

