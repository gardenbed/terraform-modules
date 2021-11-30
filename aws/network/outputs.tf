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
