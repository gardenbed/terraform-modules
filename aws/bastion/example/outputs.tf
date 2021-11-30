output "load_balancer_dns_name" {
  value = module.bastion.load_balancer_dns_name
}

output "load_balancer_public_ips" {
  value = module.bastion.load_balancer_public_ips
}

output "ssh_config_file" {
  value = module.bastion.ssh_config_file
}
