# https://www.terraform.io/docs/language/values/outputs.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

output "ssh_config_file" {
  description = "The path to SSH config file for the bastion instances."
  value       = var.enable_ssh_keys ? local_file.bastion_ssh_config.0.filename : null
}
