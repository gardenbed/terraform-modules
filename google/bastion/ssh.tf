# ====================================================================================================
#  LOAD BALANCER
# ====================================================================================================

# https://cloud.google.com/load-balancing/docs/choosing-load-balancer
# https://cloud.google.com/load-balancing/docs/network
# https://cloud.google.com/load-balancing/docs/network/networklb-backend-service

# https://cloud.google.com/load-balancing/docs/forwarding-rule-concepts
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule
resource "google_compute_forwarding_rule" "bastion_ssh" {
  count = var.enable_ssh_keys ? 1 : 0

  name                  = "${var.name}-forwarding-bastion-ssh"
  project               = var.project
  region                = var.region
  network_tier          = "STANDARD"  # PREMIUM, STANDARD
  load_balancing_scheme = "EXTERNAL"  # EXTERNAL, INTERNAL, INTERNAL_MANAGED
  ip_protocol           = "TCP"       # TCP, UDP, ESP, AH, SCTP, ICMP, L3_DEFAULT
  ports                 = [ "22" ]
  ip_address            = google_compute_address.bastion_ssh.0.id
  backend_service       = google_compute_region_backend_service.bastion_ssh.0.id
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address
resource "google_compute_address" "bastion_ssh" {
  count = var.enable_ssh_keys ? 1 : 0

  name         = "${var.name}-address-bastion-ssh"
  project      = var.project
  region       = var.region
  network_tier = "STANDARD"  # PREMIUM, STANDARD
  address_type = "EXTERNAL"  # EXTERNAL, INTERNAL
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service
resource "google_compute_region_backend_service" "bastion_ssh" {
  count = var.enable_ssh_keys ? 1 : 0

  name                  = "${var.name}-backend-bastion-ssh"
  project               = var.project
  region                = var.region
  load_balancing_scheme = "EXTERNAL"  # EXTERNAL, INTERNAL, INTERNAL_MANAGED
  protocol              = "TCP"       # TCP, UDP, HTTP, HTTPS, HTTP2, SSL, GRPC, UNSPECIFIED
  port_name             = "ssh"
  health_checks         = [ google_compute_region_health_check.bastion_ssh.0.id ]

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service#nested_backend
  backend {
    group = google_compute_region_instance_group_manager.bastion.instance_group
  }
}

# https://cloud.google.com/load-balancing/docs/health-check-concepts
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_health_check
resource "google_compute_region_health_check" "bastion_ssh" {
  count = var.enable_ssh_keys ? 1 : 0

  name                = "${var.name}-health-bastion-ssh"
  project             = var.project
  region              = var.region
  check_interval_sec  = 30
  timeout_sec         = 10
  healthy_threshold   = 3
  unhealthy_threshold = 3

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_health_check#nested_tcp_health_check
  tcp_health_check {
    port               = 22
    port_specification = "USE_FIXED_PORT"  # USE_FIXED_PORT, USE_NAMED_PORT, USE_SERVING_PORT
  }
}

# ====================================================================================================
#  SSH CONFIG
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "bastion_ssh_config" {
  count = var.enable_ssh_keys ? 1 : 0

  filename             = pathexpand("${var.ssh_path}/config-${var.name}")
  content              = data.template_file.bastion_ssh_config.0.rendered
  file_permission      = "0644"
  directory_permission = "0700"
}

# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
data "template_file" "bastion_ssh_config" {
  count = var.enable_ssh_keys ? 1 : 0

  template = file("${path.module}/sshconfig.tpl")
  vars = {
    address     = google_compute_address.bastion_ssh.0.address
    private_key = basename(var.ssh_private_key_file)
  }
}
