# ====================================================================================================
#  SSH CONFIG
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "ssh_config" {
  count = var.ssh_config_file == null ? 0 : 1

  filename = pathexpand(format("%s/config-%s",
    dirname(var.ssh_config_file.private_key_file),
    var.name,
  ))

  content              = data.template_file.ssh_config.0.rendered
  file_permission      = "0644"
  directory_permission = "0700"
}

# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
data "template_file" "ssh_config" {
  count = var.ssh_config_file == null ? 0 : 1

  template = file("${path.module}/sshconfig.tpl")
  vars = {
    address     = aws_lb.bastion.dns_name
    private_key = basename(var.ssh_config_file.private_key_file)
  }
}
