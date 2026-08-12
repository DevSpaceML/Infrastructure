data "terraform_remote_state" "dev_network" {
    backend = "s3"
    config = {
        bucket = "dev-tf-state-488347380548"
        key    = "dev/network/main/terraform.tfstate"
        region = "us-east-1"
    }
}

data "terraform_remote_state" "dev_cluster" {
    backend = "s3"
    config = {
        bucket = "dev-tf-state-488347380548"
        key    = "dev/compute/eks_cluster/main/terraform.tfstate"
        region = "us-east-1"
    }
}
