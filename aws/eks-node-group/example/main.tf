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
  private_subnet_tags = {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group#subnet_ids
    "kubernetes.io/cluster/${var.name}" = "shared"
  }
}

module "bastion" {
  source = "../../bastion"

  name                = var.name
  region              = var.region
  vpc                 = module.network.vpc
  public_subnets      = slice(module.network.public_subnets, 0, 2)
  ssh_public_key_file = var.bastion_public_key_file
}

module "cluster" {
  source = "../../eks-cluster"

  name            = var.name
  region          = var.region
  vpc_id          = module.network.vpc.id
  subnet_ids      = module.network.private_subnets.*.id
  kubeconfig_path = var.kubeconfig_path
}

module "node_group" {
  source = "../"

  name         = var.name
  cluster_name = module.cluster.name
  subnets      = module.network.private_subnets

  ssh = {
    bastion_security_group_id  = module.bastion.security_group_id
    node_group_public_key_file = var.node_group_public_key_file
  }

  ssh_config_file = {
    bastion_address             = module.bastion.load_balancer_dns_name
    bastion_private_key_file    = var.bastion_private_key_file
    node_group_private_key_file = var.node_group_private_key_file
  }
}
