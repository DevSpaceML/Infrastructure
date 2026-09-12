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
		"kubernetes.io/cluster/${var.clustername}" = "shared"
	}
}

data "aws_vpc" "existing_vpc" {
	count = var.createvpc ? 0 : 1
	id = var.vpc_id
}

locals {
  vpc_id = var.createvpc ? aws_vpc.cluster_vpc[0].id : var.vpc_id

  azs = length(slice(data.aws_availability_zones.available.names, 0, var.num_azs))
  az_count = length(local.azs)

  base_prefix = tonumber(split("/", var.cidr)[1])
  svctiers = {
	"eks_public": var.eks_prefix,
	"eks_private": var.eks_prefix,
	"rds": var.db_prefix,
	"nodegrp": var.nodegrp_prefix
  }

  tier_order = keys(local.svctiers)
  newbits_list = flatten([
	for tier in local.tier_order :
	    [for _ in range(local.az_count): local.svctiers[tier] - local.base_prefix]
     ]) 

  subnet_cidrs = cidrsubnets(local.vpc_id, local.newbits_list...)

  # Reconstruct subnet cidrs into {tier => {az => cidr}}, eliminates downstream index math
  tiers = {
	for t_idx, tier in local.tier_order : tier => {
		for az_idx, az in local.azs : az => local.subnet_cidrs[t_idx * local.az_count + az_idx]
	}
  }
}

data "aws_internet_gateway" "existing_igw" {
  count = var.createvpc ? 0 : 1

  filter {
	name = "attachment.vpc-id"
	values = [var.vpc_id]		
  }
}

data "aws_security_group" "default_sec_group" {
  vpc_id = local.vpc_id
	
  filter {
    name   = "group-name"
    values = ["default"]
  } 
}

data "aws_subnets" "eks_subnets" {
	filter {
			name = "vpc-id"
			values = [local.vpc_id]
	}
}

resource "aws_vpc_dhcp_options" "eks_dhcp_options" {
	domain_name_servers = ["AmazonProvidedDNS"]
	domain_name         = var.region == "us-east-1" ? "ec2.internal" : "${var.region}.compute.internal"
	
	tags = {
		Name = "${var.vpcname}-dhcp-options"
	}

}

resource "aws_vpc_dhcp_options_association" "eks_dhcp_options_association" {
	vpc_id = local.vpc_id
	dhcp_options_id = aws_vpc_dhcp_options.eks_dhcp_options.id

	depends_on = [ aws_vpc_dhcp_options.eks_dhcp_options ]	 
}


# Public subnet, EIP, Nat Gateway, Route Tables

resource "aws_internet_gateway" "igw_public_eks" {
	count = var.createvpc ? 1 : 0
	vpc_id = local.vpc_id

	tags = {
		Name = "${var.igw_name}"
	}
}

resource "aws_subnet" "public_subnet_eks" {
	for_each = local.tiers["eks_public"]
	availability_zone = each.key
	cidr_block = each.value
	vpc_id = local.vpc_id
	map_public_ip_on_launch = true

	tags = {
		Name = "public-subnet-${each.key}"
		"kubernetes.io/role/elb" = "1"
		"kubernetes.io/cluster/${var.clustername}" = "shared"
		availability_zone = each.key
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
	vpc_id = local.vpc_id
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

# --- EKS Private Subnets --- 

resource "aws_subnet" "private_subnet_eks" {
	for_each = local.tiers["eks_private"]
	availability_zone = each.key
	cidr_block = each.value
	vpc_id = local.vpc_id
	map_public_ip_on_launch = false

	tags = {
		Name = "private-subnet-${each.key}"
		"kubernetes.io/cluster/${var.clustername}" = "shared"
		"kubernetes.io/role/internal-elb" = "1"
		availability_zone = each.key
	}	
}

resource "aws_route_table" "eks_private_routetable" {
	count = length(aws_subnet.private_subnet_eks)
	vpc_id = local.vpc_id

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
	route_table_id =  aws_route_table.eks_private_routetable[count.index].id
}


# ------ RDS Private Subnets ------ 

resource "aws_subnet" "rds_private_subnet" {
	for_each = local.tiers["rds"]
	availability_zone = each.key
	cidr_block = each.value
	vpc_id = local.vpc_id
	map_public_ip_on_launch = false

	tags = {
		Name = "rds-private-subnet-${each.key}"
		"kubernetes.io/cluster/${var.clustername}" = "shared"
		"kubernetes.io/role/internal-elb" = "1"
		availability_zone = each.key
	}	
}

locals {
  public_subnet_ids  = aws_subnet.public_subnet_eks[*].id
  private_subnet_ids = aws_subnet.private_subnet_eks[*].id
}

/* Nodegroup Subnet, Routetable */

resource "aws_subnet" "nodegroup_private_subnet" {
	for_each = local.tiers["nodegrp"]
	availability_zone = each.key
	cidr_block = each.value
	vpc_id = local.vpc_id
	map_public_ip_on_launch = false

	tags = {
		Name = "nodegroup-private-subnet-${each.key}"
		"kubernetes.io/cluster/${var.clustername}" = "shared"
		"kubernetes.io/role/internal-elb" = "1"
		availability_zone = each.key
	}	
  
}

resource "aws_route_table" "nodegroup_private_routetable" {
	count = length(aws_subnet.nodegroup_private_subnet)
	vpc_id = local.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat_gw[count.index % length(aws_nat_gateway.eks_nat_gw)].id
  }

  tags = {
    Name = "Nodegroup-Private-RouteTable-${count.index + 1}"
  }
}

resource "aws_route_table_association" "nodegroup_private_route_association" {
	count          =  length(aws_subnet.nodegroup_private_subnet)
	subnet_id      =  aws_subnet.nodegroup_private_subnet[count.index].id
	route_table_id =  aws_route_table.nodegroup_private_routetable[count.index].id
}

/* VPC Flow Logs 

resource "aws_flow_log" "eks-vpc-flow-log" {
	log_destination = "${var.vpcname}-vpc-flow-logs"
	vpc_id = local.vpc_id
	traffic_type = "ALL"
	destination_options {
		file_format = "plain-text"
	}

	tags = {
		Name = "VPC-Flow-Logs-${var.vpcname}"
	}
}

*/



