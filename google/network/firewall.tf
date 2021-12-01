# ====================================================================================================
#  Firewall Rules
# ====================================================================================================

# https://cloud.google.com/vpc/docs/firewalls
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall

resource "google_compute_firewall" "private_self" {
  name    = "${var.name}-private-self"
  project = var.project
  network = google_compute_network.main.id

  # If both `source_tags` and `source_ranges` are set, the logic is OR.
  description   = "Allow all protocols traffic within the private subnetwork."
  direction     = "INGRESS"  # INGRESS, EGRESS
  source_tags   = [ local.access_tag_private ]
  source_ranges = concat(
    [ google_compute_subnetwork.private.ip_cidr_range ],
    google_compute_subnetwork.private.secondary_ip_range.*.ip_cidr_range,
  )

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall#nested_allow
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "private_ingress" {
  name    = "${var.name}-private-ingress"
  project = var.project
  network = google_compute_network.main.id

  # If both `source_tags` and `source_ranges` are set, the logic is OR.
  description   = "Allow SSH and HTTPS traffic from the public subnetwork."
  direction     = "INGRESS"  # INGRESS, EGRESS
  source_tags   = [ local.access_tag_public ]
  source_ranges = concat(
    [ google_compute_subnetwork.public.ip_cidr_range ],
    google_compute_subnetwork.public.secondary_ip_range.*.ip_cidr_range,
  )

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall#nested_allow
  allow {
    protocol = "tcp"
    ports    = [ "22", "443" ]
  }
}

resource "google_compute_firewall" "private_egress" {
  name    = "${var.name}-private-egress"
  project = var.project
  network = google_compute_network.main.id

  description        = "Allow all outgoing traffic to the trusted IP addresses."
  direction          = "EGRESS"  # INGRESS, EGRESS
  destination_ranges = var.private_outgoing_cidrs

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall#nested_allow
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "public_self" {
  name    = "${var.name}-public-self"
  project = var.project
  network = google_compute_network.main.id

  # If both `source_tags` and `source_ranges` are set, the logic is OR.
  description   = "Allow all protocols traffic within the public subnetwork."
  direction     = "INGRESS"  # INGRESS, EGRESS
  source_tags   = [ local.access_tag_public ]
  source_ranges = concat(
    [ google_compute_subnetwork.public.ip_cidr_range ],
    google_compute_subnetwork.public.secondary_ip_range.*.ip_cidr_range,
  )

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall#nested_allow
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "public_ingress" {
  name    = "${var.name}-public-ingress"
  project = var.project
  network = google_compute_network.main.id

  description   = "Allow SSH traffic from the trusted IP addresses."
  direction     = "INGRESS"  # INGRESS, EGRESS
  source_ranges = var.public_incoming_cidrs

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall#nested_allow
  allow {
    protocol = "tcp"
    ports    = [ "22" ]
  }
}

resource "google_compute_firewall" "public_egress" {
  name    = "${var.name}-public-egress"
  project = var.project
  network = google_compute_network.main.id

  description        = "Allow all outgoing traffic to the trusted IP addresses."
  direction          = "EGRESS"  # INGRESS, EGRESS
  destination_ranges = var.public_outgoing_cidrs

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall#nested_allow
  allow {
    protocol = "all"
  }
}
