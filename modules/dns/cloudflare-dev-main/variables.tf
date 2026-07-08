variable "appdomain" {
  description = "domain cert applies to"
  type = string
  default = "salientapps.com"
}

variable "domain_names" {
    description = "domain names for the cert"
    type = list(string)
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

variable "cert_arn"{
    description = "arn of the cert to validate"
    type = string
}

variable "cert_validation_options" {
  description = "certificate validation options"
  type = list(object({
    domain_name = string
    resource_record_name = string
    resource_record_type = string
    resource_record_value = string
  }))
}