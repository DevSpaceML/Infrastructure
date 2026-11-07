variable "apexdomain" {
  description = "apex domain name"
  type        = string
  default     = "salientapps.com"
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