# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "network" {
  source = "../../network"

  name     = var.name
  region   = var.region
  az_count = 3
}

module "bastion" {
  source = "../"

  name                = var.name
  region              = var.region
  vpc                 = module.network.vpc
  public_subnets      = module.network.public_subnets
  ssh_public_key_file = var.ssh_public_key_file
  ssh_config_file = {
    private_key_file = var.ssh_private_key_file
  }
}
