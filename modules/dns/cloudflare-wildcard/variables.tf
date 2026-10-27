variable "root_domain" {
  description = "The root domain for which to manage DNS records in Cloudflare"
  type        = string
  default     = "salientapps.com"
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_alb_dns" {
  description = "The DNS name of the AWS ALB for the persistent domains"
  type        = string
}

variable "cluster_alb_dns" {
  description = "The DNS name of the cluster ALB"
  type        = string
}