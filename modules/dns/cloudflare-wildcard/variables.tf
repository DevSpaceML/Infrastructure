variable "apexdomain" {
  description = "The root domain for which to manage DNS records in Cloudflare"
  type        = string
  default     = "salientapps.com"
}

variable "manage_apex" {
  description = "Whether to manage the apex domain DNS record"
  type        = bool
  default     = true
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "alb_dns" {
  description = "The DNS name of the ALB"
  type        = string
}
