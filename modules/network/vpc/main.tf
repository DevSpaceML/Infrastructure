#vpc module for EKS cluster

data "aws_availability_zones" "available"{
	state = "available"
}

resource "aws_vpc" "cluster_vpc" {
	count = var.createvpc ? 1 : 0
	cidr_block = var.cidr
	instance_tenancy = var.instance_tenancy

	enable_dns_hostnames = true
	enable_dns_support   = true

	tags = {
		Name = var.vpcname
		"kubernetes.io/cluster/${var.vpcname}" = "shared"
	}
}

data "aws_vpc" "clustervpcdata" {
	count = length(aws_vpc.cluster_vpc) > 0 ? 1 : 0
	
	filter {
		name = "tag:Name"
		values = [var.vpcname]
	}
}

data "aws_vpc" "existing_vpc" {
	count = var.createvpc ? 0 : 1

	filter {
    name   = "tag:vpcname"
    values = [var.vpcname]
  }
}

data "aws_internet_gateway" "existing_igw" {
  count = var.createvpc ? 0 : 1

  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.existing_vpc[0].id]
  }
  
}

data "aws_security_group" "default_sec_group" {
  vpc_id = var.createvpc ? aws_vpc.cluster_vpc[0].id : data.aws_vpc.existing_vpc[0].id
	
  filter {
    name   = "group-name"
    values = ["default"]
  } 
}

data "aws_subnets" "eks_subnets" {
	filter {
			name = "vpc-id"
			values = [data.aws_vpc.existing_vpc[0].id]
	}
}

resource "aws_vpc_dhcp_options" "eks_dhcp_options" {
	domain_name_servers = ["AmazonProvidedDNS"]
	domain_name = "ec2.internal"
	
	tags = {
		Name = "${var.vpcname}-dhcp-options"
	}

	depends_on = [ data.aws_vpc.existing_vpc ]
}

resource "aws_vpc_dhcp_options_association" "eks_dhcp_options_association" {
	vpc_id = var.createvpc? data.aws_vpc.clustervpcdata[0].id : data.aws_vpc.existing_vpc[0].id
	dhcp_options_id = aws_vpc_dhcp_options.eks_dhcp_options.id

	depends_on = [ aws_vpc_dhcp_options.eks_dhcp_options ]	 
}

resource "aws_subnet" "public_subnet_eks" {
	vpc_id = var.createvpc? data.aws_vpc.clustervpcdata[0].id : data.aws_vpc.existing_vpc[0].id
	count = length(var.public_subnet_cidr_blocks)
	cidr_block = var.public_subnet_cidr_blocks[count.index]
	availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
	map_public_ip_on_launch = true

	tags = {
		Name = "public-subnet-${count.index + 1}"
		"kubernetes.io/role/elb" = "1"
		"kubernetes.io/cluster/${var.vpcname}" = "shared"
		availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
	}	
}

resource "aws_subnet" "private_subnet_eks" {
	vpc_id = var.createvpc? data.aws_vpc.clustervpcdata[0].id : data.aws_vpc.existing_vpc[0].id
	count = length(var.private_subnet_cidr_blocks)
	cidr_block = var.private_subnet_cidr_blocks[count.index]
	availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
	map_public_ip_on_launch = false

	tags = {
		Name = "private-subnet-${count.index + 1}"
		"kubernetes.io/cluster/${var.vpcname}" = "owned"
		"kubernetes.io/role/internal-elb" = "1"
		availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
	}	
}

resource "aws_subnet" "nodegroup_private_subnet" {
	vpc_id = var.createvpc? data.aws_vpc.clustervpcdata[0].id : data.aws_vpc.existing_vpc[0].id
	count = length(var.nodegroup_pvt_subnet_cidr_blocks)
	cidr_block = var.nodegroup_pvt_subnet_cidr_blocks[count.index]
	availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
	map_public_ip_on_launch = false

	tags = {
		Name = "nodegroup-private-subnet-${count.index + 1}"
		"kubernetes.io/cluster/${var.vpcname}" = "owned"
		"kubernetes.io/role/internal-elb" = "1"
		availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
	}	
  
}

resource "aws_subnet" "rds_private_subnet" {
	vpc_id = var.createvpc? data.aws_vpc.clustervpcdata[0].id : data.aws_vpc.existing_vpc[0].id
	count = length(var.rds_private_subnet_cidr_blocks)
	cidr_block = var.rds_private_subnet_cidr_blocks[count.index]
	availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
	map_public_ip_on_launch = false

	tags = {
		Name = "rds-private-subnet-${count.index + 1}"
		"kubernetes.io/cluster/${var.vpcname}" = "owned"
		"kubernetes.io/role/internal-elb" = "1"
		availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
	}	
}

locals {
  public_subnet_ids  = aws_subnet.public_subnet_eks[*].id
  private_subnet_ids = aws_subnet.private_subnet_eks[*].id
}

resource "aws_internet_gateway" "igw_public_eks" {
	count = var.createvpc ? 1 : 0
	vpc_id = data.aws_vpc.clustervpcdata[0].id

	tags = {
		Name = "${var.igw_name}"
	}
}

resource "aws_eip" "nat-eip" {
	count    = length(aws_subnet.private_subnet_eks)
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
	vpc_id = var.createvpc? data.aws_vpc.clustervpcdata[0].id : data.aws_vpc.existing_vpc[0].id
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = var.createvpc? aws_internet_gateway.igw_public_eks[0].id : data.aws_internet_gateway.existing_igw[0].id
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
	vpc_id = var.createvpc? aws_vpc.cluster_vpc[0].id : data.aws_vpc.existing_vpc[0].id

	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = aws_nat_gateway.eks_nat_gw[count.index].id
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

resource "aws_route_table" "nodegroup_private_routetable" {
	count = length(aws_subnet.public_subnet_eks)
	vpc_id = var.createvpc? aws_vpc.cluster_vpc[0].id : data.aws_vpc.existing_vpc[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat_gw[count.index].id
  }

  tags = {
    Name = "Nodegroup-Private-RouteTable-${count.index + 1}"
  }
}

resource "aws_route_table_association" "nodegroup_private_route_association" {
	count          =  length(aws_subnet.public_subnet_eks)
	subnet_id      =  aws_subnet.nodegroup_private_subnet[count.index].id
	route_table_id = 	aws_route_table.nodegroup_private_routetable[count.index].id
}


/*
resource "aws_flow_log" "eks-vpc-flow-log" {
	log_destination = "${var.vpcname}-vpc-flow-logs"
	vpc_id = data.aws_vpc.existing_vpc[0].id
	traffic_type = "ALL"
	destination_options {
		file_format = "plain-text"
	}

	tags = {
		Name = "VPC-Flow-Logs-${var.vpcname}"
	}
}
*/




