#EKS VPC variables for VPC module

variable "name" {
	description = "Name of VPC"
	type = string
	default = "EksClusterVPC"
}

variable "region" {
	description = "aws region"
	type = string
	default = "us-east-1"
}

variable "cidr" {
	description = "Default VPC for ekscluster"
	type = string
	default = "10.0.0.0/16"
}

variable "subnet_cidr_blocks" {
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

variable "tags" {
	description = "tags for vpc"
	type = map
	default = {}
}

