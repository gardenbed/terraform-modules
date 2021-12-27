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

module "cluster" {
  source = "../"

  name               = var.name
  region             = var.region
  public_cluster     = true
  vpc_id             = module.network.vpc.id
  private_subnet_ids = module.network.private_subnets.*.id
  kubeconfig_path    = var.kubeconfig_path
}
