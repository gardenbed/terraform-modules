# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "fabric" {
  source = "../"

  name               = var.name
  region             = var.region
  az_count           = 3
  bastion_public_key = "${path.module}/${var.bastion_key_name}.pub"
}
