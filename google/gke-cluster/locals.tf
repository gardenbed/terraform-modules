# https://www.terraform.io/docs/language/values/locals.html
locals {
  master_ipv4_cidr = "10.10.10.0/28"

  service_account_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/storage.objectViewer",
    "roles/artifactregistry.reader",
  ]
}
