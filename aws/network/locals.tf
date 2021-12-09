# https://www.terraform.io/docs/language/values/locals.html
locals {
  # Total number of availability zones required
  az_len = min(
    var.az_count,
    length(data.aws_availability_zones.available.names)
  )
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones
data "aws_availability_zones" "available" {
  state = "available"
}
