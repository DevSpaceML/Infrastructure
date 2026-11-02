variable "apexdomain" {
  description = "apex domain name"
  type        = string 
}

variable "alb_dns_name" {
  description = "alb dns name"
  type        = string
}

variable "manage_apex" {
  description = "Whether to manage the apex domain DNS record"
  type        = bool
  default     = false
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}