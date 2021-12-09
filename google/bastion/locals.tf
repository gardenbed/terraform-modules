# https://www.terraform.io/docs/language/values/locals.html
locals {
  bastion_tag               = "bastion"
  default_firewall_priority = 999

  service_account_roles = var.enable_os_login ? [
    "roles/compute.osLogin",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
  ] : []
}
