# https://www.terraform.io/docs/language/values/locals.html
locals {
  cluster_version               = data.aws_eks_cluster.cluster.version
  cluster_vpc_id                = data.aws_eks_cluster.cluster.vpc_config.0.vpc_id
  cluster_subnet_ids            = data.aws_eks_cluster.cluster.vpc_config.0.subnet_ids
  cluster_security_group_id     = data.aws_eks_cluster.cluster.vpc_config.0.cluster_security_group_id
  cluster_endpoint              = data.aws_eks_cluster.cluster.endpoint
  cluster_certificate_authority = data.aws_eks_cluster.cluster.certificate_authority.0.data
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}
