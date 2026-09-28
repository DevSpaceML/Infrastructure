terraform {
  backend "s3" {
    bucket = "dev-tf-state-488347380548"
    key = "dev/alb/eks-shared-alb/terraform.tfstate"
    region = "us-east-1"
  }
}