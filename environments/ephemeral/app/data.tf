data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "dev-tf-state-488347380548"
    key = "dev/compute/ephemeral/terraform.tfstate"
    region = "us-east-1"
  }
}


data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "dev-tf-state-488347380548"
    key = "dev/network/cluster/terraform.tfstate"
    region = "us-east-1"
  }
}