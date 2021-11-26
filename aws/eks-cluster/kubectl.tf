# ====================================================================================================
#  kubectl
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "kubeconfig" {
  filename             = "${var.kubeconfig_path}/kubeconfig-${var.name}"
  content              = local.kubeconfig
  file_permission      = "0600"
  directory_permission = "0755"
}
