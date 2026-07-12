variable "cert_validation_options" {
  description = "certificate validation options"
  type = list(object({
    domain_name = string
    resource_record_name = string
    resource_record_type = string
    resource_record_value = string
  }))
}

variable "cert_arn"{
    description = "arn of the cert to validate"
    type = string
}

variable "appdomain" {
  description = "domain cert applies to"
  type = string
}