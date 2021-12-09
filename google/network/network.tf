# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#linking-gcp-resources

# ====================================================================================================
#  NETWORK
# ====================================================================================================

# https://cloud.google.com/vpc/docs/vpc
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
resource "google_compute_network" "main" {
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
#  ROUTERS
# ====================================================================================================

# https://cloud.google.com/vpc/docs/routes
# https://cloud.google.com/network-connectivity/docs/router/concepts/overview
# https://cloud.google.com/nat/docs/overview

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

# ====================================================================================================
#  FIREWALL
# ====================================================================================================

# https://cloud.google.com/vpc/docs/firewalls
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall

resource "google_compute_firewall" "public_ingress_self" {
  name    = "${var.name}-public-allow-internal"
  project = var.project
  network = google_compute_network.main.id

  description   = "Allow all internal traffic within the public subnetwork."
  priority      = local.default_firewall_priority
  direction     = "INGRESS"  # INGRESS, EGRESS
  source_ranges = local.public_subnetwork_cidr_range
  target_tags   = [ local.public_subnetwork_tag ]

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall#nested_allow

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
}

resource "google_compute_firewall" "public_ingress_icmp" {
  name    = "${var.name}-public-allow-icmp"
  project = var.project
  network = google_compute_network.main.id

  description   = "Allow ICMP traffic from the trusted IP addresses to the public subnetwork."
  priority      = local.default_firewall_priority
  direction     = "INGRESS"  # INGRESS, EGRESS
  source_ranges = var.public_incoming_cidrs
  target_tags   = [ local.public_subnetwork_tag ]

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall#nested_allow

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "public_ingress_ssh" {
  name    = "${var.name}-public-allow-ssh"
  project = var.project
  network = google_compute_network.main.id

  description   = "Allow SSH traffic from the trusted IP addresses to the public subnetwork."
  priority      = local.default_firewall_priority
  direction     = "INGRESS"  # INGRESS, EGRESS
  source_ranges = var.public_incoming_cidrs
  target_tags   = [ local.public_subnetwork_tag ]

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall#nested_allow

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "public_egress_all" {
  name    = "${var.name}-public-allow-outgoing"
  project = var.project
  network = google_compute_network.main.id

  description        = "Allow all outgoing traffic from the public subnetwork to the trusted IP addresses."
  priority           = local.default_firewall_priority
  direction          = "EGRESS"  # INGRESS, EGRESS
  destination_ranges = var.public_outgoing_cidrs
  target_tags        = [ local.public_subnetwork_tag ]

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall#nested_allow

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "private_ingress_self" {
  name    = "${var.name}-private-allow-internal"
  project = var.project
  network = google_compute_network.main.id

  description   = "Allow all internal traffic within the private subnetwork."
  priority      = local.default_firewall_priority
  direction     = "INGRESS"  # INGRESS, EGRESS
  source_ranges = local.private_subnetwork_cidr_range
  target_tags   = [ local.private_subnetwork_tag ]

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall#nested_allow

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
}

resource "google_compute_firewall" "private_ingress_ssh" {
  name    = "${var.name}-private-allow-ssh"
  project = var.project
  network = google_compute_network.main.id

  description   = "Allow SSH traffic from the public subnetwork to the private subnetwork."
  priority      = local.default_firewall_priority
  direction     = "INGRESS"  # INGRESS, EGRESS
  source_ranges = local.public_subnetwork_cidr_range
  target_tags   = [ local.private_subnetwork_tag ]

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall#nested_allow

  allow {
    protocol = "tcp"
    ports    = [ "22" ]
  }
}

resource "google_compute_firewall" "private_egress_all" {
  name    = "${var.name}-private-allow-outgoing"
  project = var.project
  network = google_compute_network.main.id

  description        = "Allow all outgoing traffic from the private subnetwork to the trusted IP addresses."
  priority           = local.default_firewall_priority
  direction          = "EGRESS"  # INGRESS, EGRESS
  destination_ranges = var.private_outgoing_cidrs
  target_tags        = [ local.private_subnetwork_tag ]

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall#nested_allow

  allow {
    protocol = "all"
  }
}
