#EKS VPC variables for VPC module

variable "vpcname" {
	description = "Name of VPC"
	type = string
}

variable "region" {
	description = "aws region"
	type = string
	default = "us-east-1"
}

variable "cidr" {
	description = "Default cidr for VPC cluster"
	type = string
}

variable "public_subnet_cidr_blocks" {
  description = "A list of CIDR blocks for the subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "A list of CIDR blocks for the subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
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

