# https://www.terraform.io/docs/language/values/outputs.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

output "security_group_id" {
  description = "The security group id of the bastion hosts."
  value       = aws_security_group.bastion.id
}

output "load_balancer_public_ips" {
  description = "The public elastic ip addresses of the load balancer."
  value       = aws_eip.bastion.*.public_ip
}

output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.bastion.dns_name
}

output "load_balancer_zone_id" {
  description = "The hosted zone ID of the load balancer to be used in a Route 53 Alias record."
  value       = aws_lb.bastion.zone_id
}

output "ssh_config_file" {
  description = "The path to SSH config file for the bastion hosts."
  value       = var.ssh_config_file == null ? null : local_file.ssh_config.0.filename
}
