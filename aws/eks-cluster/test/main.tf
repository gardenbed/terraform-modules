# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "fabric" {
  source = "../../fabric"

  name           = var.name
  region         = var.region
  az_count       = 3
  enable_bastion = false
}

module "cluster" {
  source = "../"

  name                            = var.name
  region                          = var.region
  vpc_id                          = module.fabric.vpc.id
  subnet_ids                      = [for subnet in module.fabric.private_subnets : subnet.id]
  enable_iam_role_service_account = true
}
