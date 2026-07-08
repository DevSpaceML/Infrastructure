
variable "appdomain" {
  description = "domain cert applies to"
  type = string
  default = "salientapps.com"
}

variable "subj_alt_names" {
  description = "subject alternative names for the cert"
  type = list(string)
  default = []
}

variable "alb_dns_name" {
  description = "load balancer dns name"
  type = string
}

variable "target" {
  description = "target resource for cert deployment"
  type = string
  default = "alb"
}

