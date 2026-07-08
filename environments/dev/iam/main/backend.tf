terraform {
  backend "s3" {
    bucket = "dev-tf-state-488347380548"
    key = "dev/iam/terraform.tfstate"
    region = "us-east-1"
  }
}