terraform {
  backend "s3" {
    bucket = "dev-tf-state-488347380548"
    key = "dev/alb/terraform.tfstate"
    region = "us-east-1"
  }
}