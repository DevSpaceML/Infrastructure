# get data of security group provisioned by EKS cluster

data "aws_security_group" "cluster-sg" {
    vpc_id = var.vpc_id

    filter {
        name   = "group-name"
        values = ["eks-cluster-sg-${var.clustername}-*"]
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


# rule for note-to-cluster communication
resource "aws_security_group_rule" "cluster_to_nodegroup" {
    type                     = "egress"
    from_port                = 443                
    to_port                  = 443
    protocol                 = "tcp"
    security_group_id        = aws_security_group.nodegroup-sg.id
    source_security_group_id = data.aws_security_group.cluster-sg.id
}

#rule for cluster-to-node communication
resource "aws_security_group_rule" "nodegroup_to_cluster" {
    type                     = "ingress"
    from_port                = 443                        
    to_port                  = 443
    protocol                 = "tcp"
    cidr_blocks              = var.nodegroup_cidr_blocks
    security_group_id        = data.aws_security_group.cluster-sg.id
    source_security_group_id = aws_security_group.nodegroup-sg.id
}

resource "aws_security_group_rule" "node_ingress_cluster_kubelet" {
   type = "ingress"
   from_port = 10250
   to_port = 10250
   protocol = "tcp"
   cidr_blocks = var.nodegroup_cidr_blocks
   security_group_id = aws_security_group.nodegroup-sg.id
   source_security_group_id = data.aws_security_group.cluster-sg.id
} 


