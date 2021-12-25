# https://www.terraform.io/docs/language/values/outputs.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

output "id" {
  description = "The node pool ID."
  value       = google_container_node_pool.node_pool.id
}

output "ssh_config_file" {
  description = "The path to SSH config file for the bastion instances and node pool."
  value       = var.ssh == null ? null : local_file.ssh_config.0.filename
}
