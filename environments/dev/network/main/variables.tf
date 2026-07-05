/*
variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type = string
  default = ""
}

variable "appdomain" {
  description = "Domain name for the application"
  type = string
  default = "salientapps.com"
}


variable "cert_validation_options" {
  description = "Certificate validation options"
  type = list(object({
    domain_name = string
    resource_record_name = string
    resource_record_type = string
    resource_record_value = string
  }))
}
*/