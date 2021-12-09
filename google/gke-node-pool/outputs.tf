# https://www.terraform.io/docs/language/values/outputs.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

output "id" {
  description = "The node pool ID."
  value       = google_container_node_pool.node_pool.id
}
