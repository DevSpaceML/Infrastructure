#eks variables

variable "clustername" {
	description = "Name of cluster to be provisioned"
	type = string
}

variable "k8s_version" {
	description = "Version to be used with the cluster"
	type = string
	default = "1.29"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
	description = "Environment cluster will be deployed in"
	type = string
	default = "dev"
}

variable "namespace" {
  description = "deployment namespace"
  type = string
  default = "development"
}

variable "project" {
	description = "Project running on cluster"
	type = string
	default = "development project"
}

variable "vpcId" {
	description = "ID of the VPC containing the cluster"
	type = string	
}

variable "endpoint_private_access" {
  description = "enable public server endpoint"
  type        = string
  default     = true
}

variable "endpoint_public_access" {
  description = "enable public server endpoint"
  type        = string
  default     = true
}

variable "public_subnet_ids" {
  	description = "list of subnet Ids available to the cluster"
	type = list
}

variable "public_cidr" {
	description = "Public facing CIDR block"
	type = list
}

variable "additional_security_group_ids" {
    description = "list of additional security group Ids to attach to the cluster"
	type        = list(string)
	default     = [ ]
}

variable "authentication_mode" {
  description = "Authentication mode for the cluster"
  type        = string
  default     = "API_AND_CONFIG_MAP"
  validation {
	condition     = contains(["CONFIG_MAP", "API", "API_AND_CONFIG_MAP"], var.authentication_mode)
	error_message = "Authentication mode must be one of CONFIG_MAP, API, API_AND_CONFIG_MAP."
  } 
}

variable "enabled_cluster_log_types" {
  description = "List of cluster log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "region" {
	description = "region to be deployed"
	type = string
	default = "us-east-1"
}

variable "cluster_role_arn" {
	description = "Role with eks permissions"
	type = string
}

variable "cluster_encryption_config" {
  description = "Configuration block for encrypting Kubernetes secrets"
  type        = list(object(
		{
			provider_key_arn = string
			resources        = list(string)
		}
	)
  )

  default = []
}

variable "access_entries" {
  description = "Access entries for EKS cluster"
  type = map(object({
    principal_arn      = string
    kubernetes_groups  = list(string)
    type              = string
    user_name         = optional(string)
  }))
  default = {}
}

