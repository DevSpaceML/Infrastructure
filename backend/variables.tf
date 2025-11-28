variable "environment" {
  description = "environment for tf state file"
  type = string
}

variable "projectname" {
  description = "project name for tf state bucket"
  type = string
  default = "gemapp"
}

