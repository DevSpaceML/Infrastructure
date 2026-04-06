variable "clustername" {
  description = "name of the dev cluster"
  type        = string
}

variable "region" {
  description = "aws region"
  type = string
}

variable "github_actions_arn" {
  description = "arn for github actions role"
  type = string
}
