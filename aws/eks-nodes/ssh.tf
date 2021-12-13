# ====================================================================================================
#  SSH CONFIG
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "ssh_config" {
  filename             = pathexpand("${var.ssh.path}/config-${var.name}")
  content              = data.template_file.ssh_config.rendered
  file_permission      = "0644"
  directory_permission = "0700"
}

# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
data "template_file" "ssh_config" {
  template = file("${path.module}/sshconfig.tpl")
  vars = {
    bastion_dns_name            = var.bastion.dns_name
    bastion_private_key         = basename(var.bastion.private_key_file)
    node_group_private_key      = basename(var.ssh.private_key_file)
    node_group_subnets_wildcard = join(" ", [
      for cidr in var.subnet_cidrs: replace(cidr, "0/24", "*")
    ])
  }
}
