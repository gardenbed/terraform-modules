# ====================================================================================================
#  Cluster & Nodes
# ====================================================================================================

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
    "kubernetes.io/cluster/${var.name}" = "shared"
  }
}

module "cluster" {
  source = "../../eks-cluster"

  name            = var.name
  region          = var.region
  vpc_id          = module.network.vpc.id
  subnet_ids      = module.network.private_subnets.*.id
  kubeconfig_path = var.kubeconfig_path
}

module "bastion" {
  source = "../../bastion"

  name                = var.name
  region              = var.region
  vpc                 = module.network.vpc
  public_subnets      = slice(module.network.public_subnets, 0, 2)
  ssh_public_key_file = var.bastion_public_key_file
}

module "nodes" {
  source = "../"

  name                                 = var.name
  cluster_name                         = module.cluster.name
  cluster_additional_security_group_id = module.cluster.additional_security_group_ids[0]
  subnet_cidrs                         = module.network.private_subnets.*.cidr

  ssh = {
    bastion_security_group_id = module.bastion.security_group_id
    nodes_public_key_file     = var.nodes_public_key_file
  }

  ssh_config_file = {
    bastion_address          = module.bastion.load_balancer_dns_name
    bastion_private_key_file = var.bastion_private_key_file
    nodes_private_key_file   = var.nodes_private_key_file
  }
}

# ====================================================================================================
#  Kubernetes Resources
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth
data "aws_eks_cluster_auth" "cluster" {
  name = module.cluster.name
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
provider "kubernetes" {
  host                   = module.cluster.endpoint
  cluster_ca_certificate = base64decode(module.cluster.certificate_authority)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "nodes_auth" {
  source = "../../eks-nodes-auth"

  iam_role_arns = [module.nodes.iam_role_arn]
}
