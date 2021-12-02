# https://www.terraform.io/docs/language/values/outputs.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

output "network_id" {
  description = "The VPC network ID."
  value       = google_compute_network.main.id
}

output "public_subnetwork_id" {
  description = "The VPC public subnetwork ID."
  value       = google_compute_subnetwork.public.id
}

output "private_subnetwork_id" {
  description = "The VPC private subnetwork ID."
  value       = google_compute_subnetwork.private.id
}

output "access_tag_public" {
  description = "The public subnetwork access tag value."
  value       = local.access_tag_public
}

output "access_tag_private" {
  description = "The private subnetwork access tag value."
  value       = local.access_tag_private
}
