# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#linking-gcp-resources

# ====================================================================================================
#  Network
# ====================================================================================================

# https://cloud.google.com/vpc/docs/vpc#vpc_networks_and_subnets
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
resource "google_compute_network" "main" {
  name                            = "${var.name}-network"
  project                         = var.project
  routing_mode                    = "REGIONAL"  # REGIONAL, GLOBAL
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false  # 0.0.0.0/0
}

# ====================================================================================================
#  Subnetworks
# ====================================================================================================

# https://cloud.google.com/vpc/docs/vpc#vpc_networks_and_subnets
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
resource "google_compute_subnetwork" "public" {
  name                       = "${var.name}-subnet-public"
  project                    = var.project
  region                     = var.region
  network                    = google_compute_network.main.id
  ip_cidr_range              = cidrsubnet(lookup(var.vpc_cidrs, var.region), 8, 1)
  private_ip_google_access   = false
  private_ipv6_google_access = false

  # https://cloud.google.com/vpc/docs/alias-ip
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork#nested_secondary_ip_range
  secondary_ip_range {
    range_name    = "alias-cidr"
    ip_cidr_range = cidrsubnet(lookup(var.vpc_cidrs, var.region), 8, 2)
  }

  # https://cloud.google.com/vpc/docs/using-flow-logs
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork#nested_log_config
  log_config {
    flow_sampling        = var.flow_log_sampling_rate
    aggregation_interval = "INTERVAL_5_SEC"        # INTERVAL_5_SEC, INTERVAL_30_SEC, INTERVAL_1_MIN, INTERVAL_5_MIN, INTERVAL_10_MIN, INTERVAL_15_MIN
    metadata             = "INCLUDE_ALL_METADATA"  # INCLUDE_ALL_METADATA, EXCLUDE_ALL_METADATA, CUSTOM_METADATA
  }
}

# https://cloud.google.com/vpc/docs/vpc#vpc_networks_and_subnets
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
resource "google_compute_subnetwork" "private" {
  name                       = "${var.name}-subnet-private"
  project                    = var.project
  region                     = var.region
  network                    = google_compute_network.main.id
  ip_cidr_range              = cidrsubnet(lookup(var.vpc_cidrs, var.region), 8, 128)
  private_ip_google_access   = true
  private_ipv6_google_access = true

  # https://cloud.google.com/vpc/docs/alias-ip
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork#nested_secondary_ip_range
  secondary_ip_range {
    range_name    = "alias-cidr"
    ip_cidr_range = cidrsubnet(lookup(var.vpc_cidrs, var.region), 8, 129)
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
#  Routers
# ====================================================================================================

# https://cloud.google.com/network-connectivity/docs/router
# https://cloud.google.com/network-connectivity/docs/router/concepts/overview

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router
resource "google_compute_router" "main" {
  name    = "${var.name}-router"
  project = var.project
  region  = var.region
  network = google_compute_network.main.id
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat
resource "google_compute_router_nat" "main" {
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
