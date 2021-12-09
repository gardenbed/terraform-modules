# ====================================================================================================
#  GENERAL
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
  source_ranges = [ local.public_subnetwork_cidr ]
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
  source_ranges = [ local.private_subnetwork_cidr ]
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

# ====================================================================================================
#  SPECIFIC
# ====================================================================================================

resource "google_compute_firewall" "public_ingress_icmp" {
  count = length(var.icmp_incoming_cidrs) > 0 ? 1 : 0

  name    = "${var.name}-public-allow-icmp"
  project = var.project
  network = google_compute_network.main.id

  description   = "Allow ICMP traffic from the trusted IP addresses to the public subnetwork."
  priority      = local.default_firewall_priority
  direction     = "INGRESS"  # INGRESS, EGRESS
  source_ranges = var.icmp_incoming_cidrs
  target_tags   = [ local.public_subnetwork_tag ]

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall#nested_allow

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "public_ingress_ssh" {
  count = length(var.ssh_incoming_cidrs) > 0 ? 1 : 0

  name    = "${var.name}-public-allow-ssh"
  project = var.project
  network = google_compute_network.main.id

  description   = "Allow SSH traffic from the trusted IP addresses to the public subnetwork."
  priority      = local.default_firewall_priority
  direction     = "INGRESS"  # INGRESS, EGRESS
  source_ranges = var.ssh_incoming_cidrs
  target_tags   = [ local.public_subnetwork_tag ]

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall#nested_allow

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "private_ingress_ssh" {
  count = length(var.ssh_incoming_cidrs) > 0 ? 1 : 0

  name    = "${var.name}-private-allow-ssh"
  project = var.project
  network = google_compute_network.main.id

  description   = "Allow SSH traffic from the public subnetwork to the private subnetwork."
  priority      = local.default_firewall_priority
  direction     = "INGRESS"  # INGRESS, EGRESS
  source_ranges = [ local.public_subnetwork_cidr ]
  target_tags   = [ local.private_subnetwork_tag ]

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall#nested_allow

  allow {
    protocol = "tcp"
    ports    = [ "22" ]
  }
}
