# https://www.terraform.io/docs/language/values/outputs.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

output "availability_zones" {
  description = "A list of availability zones."
  value       = slice(data.aws_availability_zones.available.names, 0, local.az_len)
}

output "vpc" {
  description = "The VPC network information."
  value = {
    id   = aws_vpc.main.id
    cidr = aws_vpc.main.cidr_block
  }
}

output "public_subnets" {
  description = "The public subnets information."
  value = [for subnet in aws_subnet.public: {
    id                = subnet.id
    cidr              = subnet.cidr_block
    availability_zone = subnet.availability_zone
  }]
}

output "private_subnets" {
  description = "The private subnets information."
  value = [for subnet in aws_subnet.private: {
    id                = subnet.id
    cidr              = subnet.cidr_block
    availability_zone = subnet.availability_zone
  }]
}

output "elastic_ips" {
  description = "A list of elastic public IP addresses."
  value       = aws_eip.nat.*.public_ip
}

output "bastion" {
  description = "The bastion hosts information."
  value = var.enable_bastion ? {
    security_group_id = aws_security_group.bastion.0.id
    public_ip         = data.aws_instance.bastion.0.public_ip
  } : null
}
