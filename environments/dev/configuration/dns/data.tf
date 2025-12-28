data "terraform_remote_state" "dev_network" {
  backend  = "s3" 
  config = { 
    bucket = "dev-terraform-state-586098609239"
    key    = "dev/network/terraform.tfstate"
    region = "us-east-1" 
  } 
}

data "terraform_remote_state" "certs" {
  backend = "s3"
    config = {
      bucket = "dev-terraform-state-586098609239"
      key = "dev/configuration/certs/terraform.tfstate"
      region = "value"
    }
}