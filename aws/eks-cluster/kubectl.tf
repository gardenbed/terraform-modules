# ====================================================================================================
#  kubectl
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
data "template_file" "kubeconfig" {
  template = file("${path.module}/kubeconfig.tpl")
  vars = {
    cluster_region                = var.region
    cluster_name                  = aws_eks_cluster.cluster.id
    cluster_endpoint              = aws_eks_cluster.cluster.endpoint
    cluster_certificate_authority = aws_eks_cluster.cluster.certificate_authority[0].data
  }
}

# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "kubeconfig" {
  filename             = "${var.kubeconfig_path}/kubeconfig-${var.name}"
  content              = data.template_file.kubeconfig.rendered
  file_permission      = "0600"
  directory_permission = "0755"
}
