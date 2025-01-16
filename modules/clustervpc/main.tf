#vpc module for EKS cluster

provider "aws" {
	region = var.region
}

data "aws_availability_zones" "available"{
	state = "available"
}

data "aws_subnets" "eks_subnets" {
	filter {
			name = "vpc-id"
			values = [aws_vpc.cluster_vpc.id]
	}

	depends_on = [aws_vpc.cluster_vpc]
}

resource "aws_vpc" "cluster_vpc" {
	cidr_block = var.cidr
	instance_tenancy = var.instance_tenancy

	tags = {
		Name = var.name
	}
}

resource "aws_subnet" "subnet_eks" {
	vpc_id = aws_vpc.cluster_vpc.id
	count = length(var.subnet_cidr_blocks)
	cidr_block = var.subnet_cidr_blocks[count.index]
	availability_zone = data.aws_availability_zones.available.names[count.index]
	map_public_ip_on_launch = true

	tags = {
		Name = "eks_subnet${count.index + 1}"
	}	
}


resource "aws_route_table_association" "eks_subnet_association" {
  count          = length(aws_subnet.subnet_eks1)
  subnet_id      = aws_subnet.subnet_eks1[count.index].id
  route_table_id = aws_route_table.eks_routetable.id

  depends_on = [aws_route_table.eks_routetable, aws_subnet.subnet_eks]
}

resource "aws_internet_gateway" "igw_internal_eks" {
	vpc_id = aws_vpc.cluster_vpc.id

	tags = {
		Name = "EKS Internet Gateway"
	}
}

resource "aws_route_table" "eks_routetable" {
	vpc_id = aws_vpc.cluster_vpc.id

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.igw_internal_eks.id
	}	
}
