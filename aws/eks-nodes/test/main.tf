# ====================================================================================================
#  Cluster & Nodes
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "fabric" {
  source = "../../fabric"

  name               = var.name
  region             = var.region
  az_count           = 3
  enable_bastion     = true
  bastion_public_key = var.bastion_public_key
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

module "nodes" {
  source = "../"

  name         = var.name
  cluster_name = module.cluster.name
  vpc_id       = module.fabric.vpc.id
  subnets      = module.fabric.private_subnets

  bastion = {
    security_group_id = module.fabric.bastion.security_group_id
    public_ip         = module.fabric.bastion.public_ip
    private_key       = var.bastion_private_key
  }

  ssh = {
    ssh_path    = var.ssh_path
    public_key  = var.nodes_public_key
    private_key = var.nodes_private_key
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
