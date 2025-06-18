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

variable "kubeadmin-arn" {
  description = "Role with eks permissions"
  type = string
  default = "arn:aws:iam::312907937200:role/ClusterAdminRole"
}

variable "devops_user" {
   description = "DevOps user account running terraform"
   type        = string
   default     = "arn:aws:iam::312907937200:user/devopsadmin"
}