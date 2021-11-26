output "name" {
  value = module.cluster.name
}

output "version" {
  value = module.cluster.version
}

output "status" {
  value = module.cluster.status
}

output "endpoint" {
  value = module.cluster.endpoint
}

output "oidc_url" {
  value = module.cluster.oidc_url
}
