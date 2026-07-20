
/* --- Public facing ec2 and subnet for static corp site ---

resource "aws_vpc" "corp_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "corp_subnet" {
  vpc_id            = data.aws_vpc.corp_vpc.id
  cidr_block        = "10.0.1.0/24"
}

*/

data "aws_availability_zones" "available"{
	state = "available"
}


/* --- Dev Resources --- */

resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_internet_gateway" "salient_igw" {
  depends_on = [ aws_vpc.dev_vpc ]
  vpc_id     = aws_vpc.dev_vpc.id
}

/* security groups */

resource "aws_security_group" "alb_sg" {
  name        = "dev-alb-sg"
  description = "Security group for dev ALB"
  vpc_id      = aws_vpc.dev_vpc.id

  tags = {
    Name        = "dev-alb-sg"
    Environment = "Dev"
  }
}

resource "aws_security_group_rule" "alb_rules" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb_sg.id
  cidr_blocks              = ["0.0.0.0/0"]
}

# 1. Internet -> ALB (this is the one you just added manually via CLI)
resource "aws_security_group_rule" "sgr-alb-ingress-443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# -- 

resource "aws_security_group_rule" "alb_egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.alb_sg.id
  cidr_blocks              = ["0.0.0.0/0"]
}

# 2. ALB -> ECS tasks (mirrors your existing port-80 pattern)
resource "aws_security_group_rule" "sgr-ecs-ingress-443" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}


/* Public subnet resources */

resource "aws_subnet" "public_dev_subnet" {
  for_each = { for idx, az in slice(data.aws_availability_zones.available.names, 0, 2) : az => idx }
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.dev_vpc.cidr_block, 4, each.value)
  availability_zone = each.key
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-dev-subnet-${each.key}"
    Environment = "Dev"
  }
}

/* Dev Gateway and Public Subnet Routes and Tables */

resource "aws_nat_gateway" "dev_nat_gateway" {
  allocation_id = aws_eip.dev_eip.id
  subnet_id     = [ for s in aws_subnet.public_dev_subnet : s.id ][0]

  tags = {
    Name        = "dev-nat-gateway"
    Environment = "Dev"
  }
}

resource "aws_route_table" "dev_public_route" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.salient_igw.id
  }

  tags = {
    Name        = "public-route"
    Environment = "Dev"
  }
}

resource "aws_eip" "dev_eip" {
  domain = "vpc"

  tags = {
    Name        = "dev-eip"
    Environment = "Dev"
  }
}

resource "aws_route_table_association" "public_dev_rta" {
  for_each       = aws_subnet.public_dev_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.dev_public_route.id
}

/** ECS Security Groups and Rules */

resource "aws_security_group" "ecs_sg" {
  name        = "dev-ecs-sg"
  description = "Security group for dev ECS"
  vpc_id      = aws_vpc.dev_vpc.id

  tags = {
    Name        = "dev-ecs-sg"
    Environment = "Dev"
  }
}

resource "aws_security_group_rule" "sgr-ecs-ingress" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "sgr-ecs-egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.ecs_sg.id
  cidr_blocks              = ["0.0.0.0/0"]
}

/** Private subnet resources */

resource "aws_subnet" "private_dev_subnet" {
  for_each = { for idx, az in slice(data.aws_availability_zones.available.names, 0, 2) : az => idx }
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.dev_vpc.cidr_block, 4, each.value + 2)
  availability_zone = each.key

  tags = {
    Name        = "private-dev-subnet-${each.key}"
    Environment = "Dev"
  }
  
}

resource "aws_subnet" "private_ecs_subnet" {
  for_each = { for idx, az in slice(data.aws_availability_zones.available.names, 0, 2) : az => idx }
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.dev_vpc.cidr_block, 4, each.value + 4)
  availability_zone = each.key

  tags = {
    Name        = "private-eks-subnet-${each.key}"
    Environment = "Dev"
  }
}

resource "aws_route_table" "dev_private_route" {
  vpc_id = aws_vpc.dev_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.dev_nat_gateway.id
  }

  tags = {
    Name = "dev-private-route"
    Environment = "dev"
  }
}

resource "aws_route_table_association" "private_ecs_rta" {
  for_each       = aws_subnet.private_ecs_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.dev_private_route.id
}
