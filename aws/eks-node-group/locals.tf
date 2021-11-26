# https://www.terraform.io/docs/language/values/locals.html
locals {
  sshconfig = templatefile("${path.module}/sshconfig.tpl", {
    bastion_public_ip           = var.bastion.public_ip
    bastion_private_key         = basename(var.bastion.private_key)
    node_group_private_key      = basename(var.ssh.private_key)
    node_group_subnets_wildcard = join(" ", [
      for subnet in var.subnets: replace(subnet.cidr, "0/24", "*")
    ])
  })
}
