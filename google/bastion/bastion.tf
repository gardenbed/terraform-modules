# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#create_before_destroy
# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#ignore_changes
#   We ignore changes to labels since they can take new values on each run (terraform plan/apply).
#   These updates are based on semantic rules managed outside of the Terraform scope.

# ====================================================================================================
#  AUTOSCALER
# ====================================================================================================

# https://cloud.google.com/compute/docs/autoscaler
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_autoscaler
resource "google_compute_region_autoscaler" "bastion" {
  name    = "${var.name}-autoscaler-bastion"
  project = var.project
  region  = var.region
  target  = google_compute_region_instance_group_manager.bastion.id

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_autoscaler#nested_autoscaling_policy
  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 1
    cooldown_period = 60
  }
}

# ====================================================================================================
#  INSTANCE GROUP MANAGER
# ====================================================================================================

# https://cloud.google.com/compute/docs/instance-groups
# https://cloud.google.com/compute/docs/instance-groups/distributing-instances-with-regional-instance-groups
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager
resource "google_compute_region_instance_group_manager" "bastion" {
  name                      = "${var.name}-manager-bastion"
  project                   = var.project
  region                    = var.region
  base_instance_name        = "${var.name}-bastion"
  distribution_policy_zones = data.google_compute_zones.available.names

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager#nested_version
  version {
    name              = "bastion"
    instance_template = google_compute_instance_template.bastion.id
  }

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager#nested_named_port
  named_port {
    name = "ssh"
    port = 22
  }

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager#auto_healing_policies
  auto_healing_policies {
    health_check      = google_compute_health_check.bastion.id
    initial_delay_sec = 30
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      distribution_policy_zones,
    ]
  }
}

# https://cloud.google.com/load-balancing/docs/health-check-concepts
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check
resource "google_compute_health_check" "bastion" {
  name                = "${var.name}-health-bastion"
  project             = var.project
  check_interval_sec  = 30
  timeout_sec         = 10
  healthy_threshold   = 3
  unhealthy_threshold = 3

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check#nested_tcp_health_check
  tcp_health_check {
    port               = 22
    port_specification = "USE_FIXED_PORT"  # USE_FIXED_PORT, USE_NAMED_PORT, USE_SERVING_PORT
  }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones
data "google_compute_zones" "available" {
  project = var.project
  region  = var.region
}

# ====================================================================================================
#  INSTANCE TEMPLATE
# ====================================================================================================

# https://cloud.google.com/compute/docs/instance-templates
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template
resource "google_compute_instance_template" "bastion" {
  name         = "${var.name}-template-bastion"
  project      = var.project
  region       = var.region
  machine_type = var.machine_type

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template#nested_disk
  disk {
    boot         = true
    auto_delete  = true
    source_image = data.google_compute_image.bastion.id
    disk_type    = "pd-standard"  # pd-ssd, local-ssd, pd-balanced, pd-standard
    disk_size_gb = 50
  }

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template#nested_network_interface
  network_interface {
    subnetwork = var.public_subnetwork.id
  }

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template#nested_service_account
  service_account {
    email  = google_service_account.bastion.email
    scopes = [ "cloud-platform" ]
  }

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template#nested_shielded_instance_config
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template#nested_scheduling
  scheduling {
    automatic_restart = true
    preemptible       = false
  }

  # https://cloud.google.com/compute/docs/instances/access-overview
  # https://cloud.google.com/compute/docs/instances/managing-instance-access#enable_oslogin
  # https://cloud.google.com/compute/docs/connect/add-ssh-keys#after-vm-creation
  metadata = merge(
    var.enable_os_login ? { enable-oslogin = "TRUE" } : {},
    var.enable_ssh_keys ? { ssh-keys = format("admin:%s", file(var.ssh_public_key_file)) } : {}
  )

  tags = concat(var.network_tags, [
    local.bastion_tag,
    var.public_subnetwork.network_tag,
  ])

  labels = merge(var.common_labels, {
    name = format("%s-bastion", var.name)
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      labels,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image
data "google_compute_image" "bastion" {
  family  = "debian-11"
  project = "debian-cloud"
}

# ====================================================================================================
#  SERVICE ACCOUNT
# ====================================================================================================

# https://cloud.google.com/compute/docs/access/service-accounts
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "bastion" {
  account_id   = "${var.name}-bastion"
  project      = var.project
  display_name = "Bastion Service Account"
}

# ====================================================================================================
#  FIREWALL
# ====================================================================================================

# https://cloud.google.com/vpc/docs/firewalls
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
resource "google_compute_firewall" "bastion_ingress_iap" {
  name    = "${var.name}-bastion-allow-iap"
  project = var.project
  network = var.network.id

  description = "Allow SSH traffic from IAP to bastion instances."
  priority    = local.default_firewall_priority
  direction   = "INGRESS"  # INGRESS, EGRESS
  target_tags = [ var.public_subnetwork.network_tag, local.bastion_tag ]

  source_ranges = toset([
    "35.235.240.0/20",                                      # IAP Forwarding:  https://cloud.google.com/iap/docs/using-tcp-forwarding#create-firewall-rule
    "35.191.0.0/16", "130.211.0.0/22",                      # Health Checking: https://cloud.google.com/load-balancing/docs/health-checks#fw-rule
    "35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22",  # Health Checking: https://cloud.google.com/load-balancing/docs/health-checks#fw-netlb
  ])

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall#nested_allow

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
