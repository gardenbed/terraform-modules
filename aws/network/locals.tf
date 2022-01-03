# https://www.terraform.io/docs/language/values/locals.html
locals {
  # Total number of availability zones required
  az_len = min(
    var.az_count,
    length(data.aws_availability_zones.available.names)
  )

  public_subnet_cidr  = cidrsubnet(lookup(var.vpc_cidrs, var.region), 1, 0)
  private_subnet_cidr = cidrsubnet(lookup(var.vpc_cidrs, var.region), 1, 1)
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones
data "aws_availability_zones" "available" {
  state = "available"
}
