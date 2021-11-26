# ====================================================================================================
#  kubectl
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "kubeconfig" {
  content              = local.kubeconfig
  filename             = "${var.kubeconfig_path}/kubeconfig_${var.name}"
  file_permission      = "0600"
  directory_permission = "0755"
}
