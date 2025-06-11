#eks variables

variable "k8s_version" {
	description = "Version to be used with the cluster"
	type = string
	default = "1.29"
}

variable "environment" {
	description = "Environment cluster will be deployed in"
	type = string
	default = "development"
}

variable "project" {
	description = "Project running on cluster"
	type = string
	default = "development project"
}

variable "clustername" {
	description = "Name of cluster to be provisioned"
	type = string
}

variable "vpcId" {
	description = "ID of the VPC containing the cluster"
	type = string	
}

variable "public_subnet_ids" {
  	description = "list of subnet Ids available to the cluster"
	type = list
}

variable "private_subnet_Ids" {
	description = "list of subnet Ids available to the cluster"
	type = list
}

variable "public_cidr" {
	description = "Public facing CIDR block"
	type = list
}

variable "region" {
	description = "region to be deployed"
	type = string
	default = "us-east-1"
}

variable "EksClusterRole-arn" {
	description = "Role with eks permissions"
	type = string
}

variable "EksNodeGroupMgrArn" {
  description = "Role with node management permissions"
  type = string
}

variable "kubeadmin-arn" {
  description = "Role with eks permissions"
  type = string
  default = "arn:aws:iam::312907937200:role/ClusterAdminRole"
}

variable "nodegroupname" {
	description = "Name of the nodegroup"
	type = string
	default = "cluster_nodes"
}

variable "instancetype" {
	description = "Default Instance Type"
	type = string
	default = "t4g.small"
}

variable "desired_node_count" {
	description = "number of nodes requested by user"
	type = number
	default = 3
}

variable "max_node_count" {
	description = "max nodes allowed"
	type = number
	default = 6
}

variable "min_node_count" {
	description = "minimum nodes for any deployment"
	type = number
	default = 2
}

variable "devops_user" {
   description = "DevOps user account running terraform"
   type        = string
   default     = "arn:aws:iam::312907937200:user/devopsadmin"
}