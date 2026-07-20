terraform{
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
        cloudflare = {
            source  = "cloudflare/cloudflare"
            version = "~> 5.21"
        }
    }
}

module "dev_certs" {
  source = "../../../../../modules/security/certs/alb-certs"
}