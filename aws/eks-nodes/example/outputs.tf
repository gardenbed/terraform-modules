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

output "kubeconfig_file" {
  value = module.cluster.kubeconfig_file
}

output "ssh_config_file" {
  value = module.nodes.ssh_config_file
}
