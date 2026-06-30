variable "target" {
  description = "target resource for cert deployment"
  type = string
  default = "alb"
}

variable "appdomain" {
  description = "domain cert applies to"
  type = string
  default = "salientapps.com"
}

variable "api-token" {
  description = "cloudflare auth token"
  type = string
  default = null
}

variable "alb_dns_name" {
  description = "load balancer dns name"
  type = string
}
