terraform {
  backend "s3" {
    bucket = "dev-tf-state-488347380548"
    key = "dev/configuration/k8auth/terraform.tfstate"
    region = "us-east-1"
  }
}