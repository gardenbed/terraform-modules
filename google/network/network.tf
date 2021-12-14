# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#linking-gcp-resources

# ====================================================================================================
#  NETWORK
# ====================================================================================================

# https://cloud.google.com/vpc/docs/vpc
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
resource "google_compute_network" "vpc" {
  name                            = "${var.name}-network"
  project                         = var.project
  routing_mode                    = "REGIONAL"  # REGIONAL, GLOBAL
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false  # Internet route (0.0.0.0/0)
}

# ====================================================================================================
#  SUBNETWORKS
# ====================================================================================================

# https://cloud.google.com/vpc/docs/vpc
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork

resource "google_compute_subnetwork" "public" {
  name                     = "${var.name}-subnet-public"
  project                  = var.project
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = cidrsubnet(local.public_subnetwork_cidr, 2, 0)
  private_ip_google_access = false

  # https://cloud.google.com/vpc/docs/alias-ip
  # https://www.terraform.io/docs/language/expressions/dynamic-blocks.html
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork#nested_secondary_ip_range
  dynamic "secondary_ip_range" {
    for_each = var.public_secondary_ranges
    content {
      range_name    = secondary_ip_range.value
      ip_cidr_range = cidrsubnet(local.public_subnetwork_cidr, 2, secondary_ip_range.key + 1)
    }
  }

  # https://cloud.google.com/vpc/docs/using-flow-logs
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork#nested_log_config
  log_config {
    flow_sampling        = var.flow_log_sampling_rate
    aggregation_interval = "INTERVAL_5_SEC"        # INTERVAL_5_SEC, INTERVAL_30_SEC, INTERVAL_1_MIN, INTERVAL_5_MIN, INTERVAL_10_MIN, INTERVAL_15_MIN
    metadata             = "INCLUDE_ALL_METADATA"  # INCLUDE_ALL_METADATA, EXCLUDE_ALL_METADATA, CUSTOM_METADATA
  }
}

resource "google_compute_subnetwork" "private" {
  name                     = "${var.name}-subnet-private"
  project                  = var.project
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = cidrsubnet(local.private_subnetwork_cidr, 2, 0)
  private_ip_google_access = true

  # https://cloud.google.com/vpc/docs/alias-ip
  # https://www.terraform.io/docs/language/expressions/dynamic-blocks.html
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork#nested_secondary_ip_range
  dynamic "secondary_ip_range" {
    for_each = var.private_secondary_ranges
    content {
      range_name    = secondary_ip_range.value
      ip_cidr_range = cidrsubnet(local.private_subnetwork_cidr, 2, secondary_ip_range.key + 1)
    }
  }

  # https://cloud.google.com/vpc/docs/using-flow-logs
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork#nested_log_config
  log_config {
    flow_sampling        = var.flow_log_sampling_rate
    aggregation_interval = "INTERVAL_5_SEC"        # INTERVAL_5_SEC, INTERVAL_30_SEC, INTERVAL_1_MIN, INTERVAL_5_MIN, INTERVAL_10_MIN, INTERVAL_15_MIN
    metadata             = "INCLUDE_ALL_METADATA"  # INCLUDE_ALL_METADATA, EXCLUDE_ALL_METADATA, CUSTOM_METADATA
  }
}

# ====================================================================================================
#  NAT
# ====================================================================================================

# https://cloud.google.com/vpc/docs/routes
# https://cloud.google.com/network-connectivity/docs/router/concepts/overview
# https://cloud.google.com/nat/docs/overview

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router
resource "google_compute_router" "nat" {
  name    = "${var.name}-router"
  project = var.project
  region  = var.region
  network = google_compute_network.vpc.id
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat
resource "google_compute_router_nat" "nat" {
  name                               = "${var.name}-router-nat"
  project                            = var.project
  region                             = var.region
  router                             = google_compute_router.main.name
  nat_ip_allocate_option             = "AUTO_ONLY"            # AUTO_ONLY, MANUAL_ONLY
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"  # ALL_SUBNETWORKS_ALL_IP_RANGES, ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES, LIST_OF_SUBNETWORKS

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat#nested_subnetwork
  subnetwork {
    name                    = google_compute_subnetwork.public.id
    source_ip_ranges_to_nat = [ "ALL_IP_RANGES" ]  # ALL_IP_RANGES, PRIMARY_IP_RANGE, LIST_OF_SECONDARY_IP_RANGES
  }

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat#nested_subnetwork
  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = [ "ALL_IP_RANGES" ]  # ALL_IP_RANGES, PRIMARY_IP_RANGE, LIST_OF_SECONDARY_IP_RANGES
  }
}
