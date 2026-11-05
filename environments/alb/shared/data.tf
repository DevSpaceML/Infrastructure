data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "dev-tf-state-488347380548"
    key    = "dev/ephemeral/cluster/terraform.tfstate"
    region = "us-east-1"
  }
}