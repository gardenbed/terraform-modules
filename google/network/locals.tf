# https://www.terraform.io/docs/language/values/locals.html
locals {
  default_firewall_priority = 1000

  public_subnetwork_tag        = "public"
  public_subnetwork_cidr_range = concat(
    [ google_compute_subnetwork.public.ip_cidr_range ],
    google_compute_subnetwork.public.secondary_ip_range.*.ip_cidr_range,
  )

  private_subnetwork_tag        = "private"
  private_subnetwork_cidr_range = concat(
    [ google_compute_subnetwork.private.ip_cidr_range ],
    google_compute_subnetwork.private.secondary_ip_range.*.ip_cidr_range,
  )
}
