output "vpc" {
  value = module.fabric.vpc
}

output "public_subnets" {
  value = module.fabric.public_subnets
}

output "private_subnets" {
  value = module.fabric.private_subnets
}

output "elastic_ips" {
  value = module.fabric.elastic_ips
}
