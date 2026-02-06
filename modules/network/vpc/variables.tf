#EKS VPC variables for VPC module
variable "createvpc" {
  description = "creates dedicated vpc if true"
  type = bool
  default = false
}

variable "vpcname" {
	description = "Name of VPC"
	type = string
}

variable "region" {
	description = "aws region"
	type = string
	default = "us-east-2"
}

variable "cidr" {
	description = "Default cidr for VPC cluster"
	type = string
}

variable "public_subnet_cidr_blocks" {
  description = "Public Cidr blocks for NAT gateways, ALB, etc"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "A list of CIDR blocks for the subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "rds_private_subnet_cidr_blocks" {
    description = "list of cidr blocks for RDS instances"
	type = list(string)
	default = ["10.0.31.0/24", "10.0.32.0/24"]
}

variable nodegroup_pvt_subnet_cidr_blocks {
	description = "list if cidr blocks for nodegroup private subnets"
	type = list
	default = ["10.0.64.0/24", "10.0.65.0/24", "10.0.66.0/24"]
}

variable "instance_tenancy" {
	description = "Tenancy of ec2 instances in this VPC"
	type = string
	default = "default"
}

variable "enable_dns_hostnames" {
	description = "should be true to enable dns-hostnames"
	type = string
	default = true
}

variable "igw_name"{
	default = "eks-gateway"
}

variable "tags" {
	description = "tags for vpc"
	type = map
	default = {}
}

