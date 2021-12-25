output "cluster_id" {
  value = module.cluster.id
}

output "cluster_name" {
  value = module.cluster.name
}

output "cluster_version" {
  value = module.cluster.version
}

output "cluster_services_cidr" {
  value = module.cluster.services_cidr
}

output "cluster_endpoint" {
  value = module.cluster.endpoint
}

output "cluster_cluster_ca_cert" {
  sensitive = true
  value     = module.cluster.cluster_ca_cert
}

output "cluster_client_cert" {
  sensitive = true
  value     = module.cluster.client_cert
}

output "cluster_client_key" {
  sensitive = true
  value     = module.cluster.client_key
}

output "cluster_service_account_email" {
  value = module.cluster.service_account_email
}

output "node_pool_id" {
  value = module.node_pool.id
}

output "kubeconfig_file" {
  value = module.cluster.kubeconfig_file
}

output "ssh_config_file" {
  value = module.node_pool.ssh_config_file
}
