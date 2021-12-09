# https://www.terraform.io/docs/language/values/outputs.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

output "network" {
  description = "The VPC network information."
  value = {
    name      = google_compute_network.main.name
    id        = google_compute_network.main.id
    self_link = google_compute_network.main.self_link
  }
}

output "public_subnetwork" {
  description = "The VPC public subnetwork information."
  value = {
    name         = google_compute_subnetwork.public.name
    id           = google_compute_subnetwork.public.id
    self_link    = google_compute_subnetwork.public.self_link
    network_tag  = local.public_subnetwork_tag

    primary_cidr    = google_compute_subnetwork.public.ip_cidr_range
    secondary_cidrs = zipmap(
      google_compute_subnetwork.public.secondary_ip_range.*.range_name,
      google_compute_subnetwork.public.secondary_ip_range.*.ip_cidr_range,
    )
  }
}

output "private_subnetwork" {
  description = "The VPC private subnetwork information."
  value = {
    name         = google_compute_subnetwork.private.name
    id           = google_compute_subnetwork.private.id
    self_link    = google_compute_subnetwork.private.self_link
    network_tag  = local.private_subnetwork_tag

    primary_cidr    = google_compute_subnetwork.private.ip_cidr_range
    secondary_cidrs = zipmap(
      google_compute_subnetwork.private.secondary_ip_range.*.range_name,
      google_compute_subnetwork.private.secondary_ip_range.*.ip_cidr_range,
    )
  }
}
