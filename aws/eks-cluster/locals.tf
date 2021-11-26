# https://www.terraform.io/docs/language/values/locals.html
locals {
  kubeconfig = templatefile("${path.module}/kubeconfig.tpl", {
    cluster_region                = var.region
    cluster_name                  = aws_eks_cluster.cluster.id
    cluster_endpoint              = aws_eks_cluster.cluster.endpoint
    cluster_certificate_authority = aws_eks_cluster.cluster.certificate_authority[0].data
  })
}
