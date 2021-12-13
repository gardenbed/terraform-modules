# https://www.terraform.io/docs/language/values/outputs.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

output "address" {
  description = "The external IP address of the load balancer."
  value = google_compute_address.bastion_ssh.0.address
}

output "ssh_config_file" {
  description = "The path to SSH config file for the bastion instances."
  value       = var.ssh_path == null ? null : local_file.ssh_config.0.filename
}
