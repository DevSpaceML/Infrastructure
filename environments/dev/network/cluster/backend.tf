terraform {
  backend "s3" {
    bucket = "dev-tf-state-488347380548"
    key = "dev/network/cluster/terraform.tfstate"
    region = "us-east-1"
  }
}