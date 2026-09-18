#EKS VPC variables for VPC module
variable "clustername" {
  description = "cluster name for subnet tags"
  type = string
  default = null
}

variable "region" {
	description = "aws region"
	type = string
}

variable "createvpc" {
  description = "creates dedicated vpc if true"
  type = bool
  default = false
}

variable "vpc_id" {
  description = "required if createvpc is false"
  type = string
  default = null
}

variable "vpcname" {
	description = "Name of VPC"
	type = string
}

variable "cidr" {
	description = "Default cidr for VPC cluster"
	type = string
	default = "10.0.0.0/16"
}

/*

variable "public_subnet_cidr_blocks" {
  description = "Public Cidr blocks for NAT gateways, ALB, etc"
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "A list of CIDR blocks for the subnets"
  type        = list(string)
}

variable "rds_private_subnet_cidr_blocks" {
    description = "list of cidr blocks for RDS instances"
	type = list(string)
	default = []
}

variable nodegroup_pvt_subnet_cidr_blocks {
	description = "list of cidr blocks for nodegroup private subnets"
	type = list
	default = []
}

*/

variable "eks_prefix"{
	description = "prefix for eks subnets"
	type = number
	default = 22
}

variable "nodegrp_prefix"{
	description = "prefix for nodegroup subnets"
	type = number
	default = 20
}

variable "db_prefix" {
	description = "prefix for database subnets"
	type = number
	default = 27
}

variable "num_azs" {
  description = "number of availability zones to use"
  type        = number
  default     = 2
}

# ---- 
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

