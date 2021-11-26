output "cluster_name" {
  value = module.cluster.name
}

output "cluster_version" {
  value = module.cluster.version
}

output "cluster_status" {
  value = module.cluster.status
}

output "cluster_endpoint" {
  value = module.cluster.endpoint
}

output "cluster_oidc_url" {
  value = module.cluster.oidc_url
}

output "nodes_iam_role_arn" {
  value = module.nodes.iam_role_arn
}

output "nodes_min_size" {
  value = module.nodes.min_size
}

output "nodes_desired_capacity" {
  value = module.nodes.desired_capacity
}

output "nodes_max_size" {
  value = module.nodes.max_size
}
