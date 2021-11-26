# ====================================================================================================
#  ssh
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
data "template_file" "ssh_config" {
  template = file("${path.module}/sshconfig.tpl")
  vars = {
    bastion_public_ip           = var.bastion.public_ip
    bastion_private_key         = basename(var.bastion.private_key)
    node_group_private_key      = basename(var.ssh.private_key)
    node_group_subnets_wildcard = join(" ", [
      for subnet in var.subnets: replace(subnet.cidr, "0/24", "*")
    ])
  }
}

# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "sshconfig" {
  filename             = "${var.ssh.ssh_path}/config-${var.name}"
  content              = data.template_file.ssh_config.rendered
  file_permission      = "0600"
  directory_permission = "0700"
}
