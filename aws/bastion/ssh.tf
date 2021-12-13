# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "ssh_config" {
  count = var.ssh_path == null ? 0 : 1

  filename             = pathexpand("${var.ssh_path}/config-${var.name}")
  content              = data.template_file.ssh_config.0.rendered
  file_permission      = "0644"
  directory_permission = "0700"
}

# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
data "template_file" "ssh_config" {
  count = var.ssh_path == null ? 0 : 1

  template = file("${path.module}/sshconfig.tpl")
  vars = {
    dns_name    = aws_lb.bastion.dns_name
    private_key = basename(var.private_key_file)
  }
}
