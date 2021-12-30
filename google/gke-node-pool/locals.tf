# https://www.terraform.io/docs/language/values/locals.html
locals {
  zone_count       = length(data.google_compute_zones.available.names)
  total_node_count = local.zone_count * var.initial_node_count 
}
