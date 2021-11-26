# ====================================================================================================
#  ssh
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "sshconfig" {
  filename             = "${var.ssh.ssh_path}/config-${var.name}"
  content              = local.sshconfig
  file_permission      = "0600"
  directory_permission = "0700"
}
