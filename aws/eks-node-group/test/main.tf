# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "fabric" {
  source = "../../fabric"

  name                = var.name
  region              = var.region
  az_count            = 3
  enable_bastion      = true
  bastion_public_key  = var.bastion_public_key
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
  }
}

module "cluster" {
  source = "../../eks-cluster"

  name                            = var.name
  region                          = var.region
  vpc_id                          = module.fabric.vpc.id
  subnet_ids                      = [for subnet in module.fabric.private_subnets : subnet.id]
  enable_iam_role_service_account = true
}

module "node_group" {
  source = "../"

  name         = var.name
  cluster_name = module.cluster.name
  subnets      = module.fabric.private_subnets

  bastion = {
    security_group_id = module.fabric.bastion.security_group_id
    public_ip         = module.fabric.bastion.public_ip
    private_key       = var.bastion_private_key
  }

  ssh = {
    ssh_path    = var.ssh_path
    public_key  = var.node_group_public_key
    private_key = var.node_group_private_key
  }
}
