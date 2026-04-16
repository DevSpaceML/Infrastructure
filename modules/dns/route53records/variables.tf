variable "deployment" {
  description = "app deployment name"
  type = string
}

variable "zone_id" {
  description = "route53 hosted zone id"
  type = string
}

variable "securitygroupId" {
    description = "security groups of cluster vpc"
	type = string
}

variable "private_cidr_blocks" {
	description = "private cidr block"
	type        =  list(string)
}

variable "public_cidr_blocks" {
	description = "public cidr block"
	type        =  list(string)
}

variable "certarn" {
  description = "arn of the eks certificate"
  type        = string
}

variable "ekscertificate" {
  description = "ACM Certificate"
  type = object({
    domain_validation_options = list(object({
      domain_name           = string
      resource_record_name  = string
      resource_record_type  = string
      resource_record_value = string
    }))
  })
}
