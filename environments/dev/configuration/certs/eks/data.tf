data "terraform_remote_state" "dev_network" {
    backend = "s3"
    config = {
        bucket = "dev-terraform-state-488347380548"
        key    = "dev/network/terraform.tfstate"
        region = "us-east-1"
    }
}

data "terraform_remote_state" "dev_cluster" {
    backend = "s3"
    config = {
        bucket = "dev-terraform-state-488347380548"
        key    = "dev/cluster/terraform.tfstate"
        region = "us-east-1"
    }
}
