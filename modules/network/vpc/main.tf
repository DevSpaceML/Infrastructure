#vpc module for EKS cluster

data "aws_availability_zones" "available"{
	state = "available"
}

data "aws_vpc" "clustervpcdata" {
	depends_on = [aws_vpc.cluster_vpc]
	
	filter {
		name = "tag:Name"
		values = [var.vpcname]
	}

}

data "aws_subnets" "eks_subnets" {
	filter {
			name = "vpc-id"
			values = [data.aws_vpc.clustervpcdata.id]
	}
}

resource "aws_vpc" "cluster_vpc" {
	cidr_block = var.cidr
	instance_tenancy = var.instance_tenancy

	tags = {
		Name = var.vpcname
		"kubernetes.io/cluster/${var.vpcname}" = "shared"
	}
}

resource "aws_subnet" "public_subnet_eks" {
	vpc_id = aws_vpc.cluster_vpc.id
	count = length(var.public_subnet_cidr_blocks)
	cidr_block = var.public_subnet_cidr_blocks[count.index]
	availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
	map_public_ip_on_launch = true

	tags = {
		Name = "eks-public-subnet-${count.index + 1}"
		"kubernetes.io/role/elb" = "1"
	}	
}

resource "aws_subnet" "private_subnet_eks" {
	vpc_id = aws_vpc.cluster_vpc.id
	count = length(var.private_subnet_cidr_blocks)
	cidr_block = var.private_subnet_cidr_blocks[count.index]
	availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
	map_public_ip_on_launch = false

	tags = {
		Name = "eks-private-subnet-${count.index + 1}"
		"kubernetes.io/cluster/${var.vpcname}" = "owned"
	}	
}

resource "aws_internet_gateway" "igw_internal_eks" {
	vpc_id = aws_vpc.cluster_vpc.id

	tags = {
		Name = "${var.igw_name}"
	}
}

resource "aws_eip" "nat-eip" {
	count    = length(aws_subnet.public_subnet_eks)
	domain   = "vpc"

	tags = {
		Name = "NAT-EIP-${count.index + 1}"
	}
	
}

resource "aws_nat_gateway" "eks_nat_gw" {
	count = length(aws_subnet.public_subnet_eks)
	allocation_id = aws_eip.nat-eip[count.index].id
	subnet_id = aws_subnet.public_subnet_eks[count.index].id

	tags = {
		Name = "EKS-NAT-Gateway-${count.index+1}"
	}
}

resource "aws_route_table" "eks_public_routetable" {
	vpc_id = aws_vpc.cluster_vpc.id

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.igw_internal_eks.id
	}	
}

resource "aws_route_table_association" "eks_public_route_association" {
  count          = length(aws_subnet.public_subnet_eks)
  subnet_id      = aws_subnet.public_subnet_eks[count.index].id
  route_table_id = aws_route_table.eks_public_routetable.id

  depends_on = [aws_route_table.eks_public_routetable, aws_subnet.public_subnet_eks]
}

resource "aws_route_table" "eks_private_routetable" {
	count = length(aws_subnet.private_subnet_eks)
	vpc_id = aws_vpc.cluster_vpc.id

	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = aws_nat_gateway.eks_nat_gw[count.index % length(aws_nat_gateway.eks_nat_gw)].id
	}

	tags = {
		Name = "Eks-Private-RouteTable-${count.index + 1}"
	}
}

resource "aws_route_table_association" "eks_private_route_association" {
	count          =  length(aws_subnet.private_subnet_eks)
	subnet_id      =  aws_subnet.private_subnet_eks[count.index].id
	route_table_id = 	aws_route_table.eks_private_routetable[count.index].id
}

/*
resource "aws_flow_log" "eks-vpc-flow-log" {
	log_destination = "${var.vpcname}-vpc-flow-logs"
	vpc_id = aws_vpc.cluster_vpc.id
	traffic_type = "ALL"
	destination_options {
		file_format = "plain-text"
	}

	tags = {
		Name = "VPC-Flow-Logs-${var.vpcname}"
	}
}
*/




