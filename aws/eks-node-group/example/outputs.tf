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

output "node_group_name" {
  value = module.node_group.name
}

output "node_group_status" {
  value = module.node_group.status
}

output "bastion_address" {
  value = module.bastion.load_balancer_dns_name
}

output "node_group_instances" {
  value = module.node_group.instances
}

output "kubeconfig_file" {
  value = module.cluster.kubeconfig_file
}

output "ssh_config_file" {
  value = module.node_group.ssh_config_file
}
