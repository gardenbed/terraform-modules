# ====================================================================================================
#  SSH CONFIG
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "ssh_config" {
  filename = pathexpand(format("%s/config-%s",
    dirname(var.ssh_config_file.nodes_private_key_file),
    var.name,
  ))

  content              = data.template_file.ssh_config.rendered
  file_permission      = "0644"
  directory_permission = "0700"
}

# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
data "template_file" "ssh_config" {
  template = file("${path.module}/sshconfig.tpl")
  vars = {
    bastion_address     = var.ssh_config_file.bastion_address
    bastion_private_key = basename(var.ssh_config_file.bastion_private_key_file)
    nodes_private_key   = basename(var.ssh_config_file.nodes_private_key_file)
    nodes_cidr_wildcard = join(" ", [
      for cidr in var.subnet_cidrs: replace(cidr, "0/24", "*")
    ])
  }
}
