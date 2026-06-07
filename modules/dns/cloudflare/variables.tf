variable "root_domain" {
  description = "The root domain for which to manage DNS records in Cloudflare"
  type        = string
  default     = "salientapps.com"
}

variable "persistent_domains" {
  description = " permanent domains needing Cloudflare CNAME records at infra creation time"
  type        = list(string)
  default     = ["*.dev.salientapps.com", "*.staging.salientapps.com", "www.salientapps.com"]
}

variable "aws_alb_dns" {
  description = "The DNS name of the AWS ALB for the persistent domains"
  type        = string
}

variable "cluster_alb_dns" {
  description = "The DNS name of the cluster ALB"
  type        = string
}