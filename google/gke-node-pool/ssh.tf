# ====================================================================================================
#  SSH CONFIG
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "ssh_config" {
  count = var.ssh == null ? 0 : 1

  filename = pathexpand(format("%s/config-%s",
    dirname(var.ssh_config_file.node_pool_private_key_file),
    var.name,
  ))

  content              = data.template_file.ssh_config.0.rendered
  file_permission      = "0644"
  directory_permission = "0700"
}

# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
data "template_file" "ssh_config" {
  count = var.ssh == null ? 0 : 1

  template = file("${path.module}/sshconfig.tpl")
  vars = {
    bastion_address         = var.ssh_config_file.bastion_address
    bastion_private_key     = basename(var.ssh_config_file.bastion_private_key_file)
    node_pool_private_key   = basename(var.ssh_config_file.node_pool_private_key_file)
    node_pool_cidr_wildcard = replace(var.ssh_config_file.node_pool_cidr, "0.0/16", "*.*")
  }
}
