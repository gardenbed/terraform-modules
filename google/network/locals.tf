# https://www.terraform.io/docs/language/values/locals.html
locals {
  default_firewall_priority = 1000

  public_subnetwork_tag  = "public"
  public_subnetwork_cidr = cidrsubnet(lookup(var.vpc_cidrs, var.region), 1, 0)

  private_subnetwork_tag  = "private"
  private_subnetwork_cidr = cidrsubnet(lookup(var.vpc_cidrs, var.region), 1, 1)
}
