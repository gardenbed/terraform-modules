output "id" {
  value = module.cluster.id
}

output "name" {
  value = module.cluster.name
}

output "version" {
  value = module.cluster.version
}

output "services_cidr" {
  value = module.cluster.services_cidr
}

output "endpoint" {
  value = module.cluster.endpoint
}

output "cluster_ca_cert" {
  sensitive = true
  value     = module.cluster.cluster_ca_cert
}

output "client_cert" {
  sensitive = true
  value     = module.cluster.client_cert
}

output "client_key" {
  sensitive = true
  value     = module.cluster.client_key
}

output "service_account_email" {
  value = module.cluster.service_account_email
}
