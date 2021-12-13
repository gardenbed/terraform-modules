# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#create_before_destroy
# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#ignore_changes
#   We ignore changes to labels since they can take new values on each run (terraform plan/apply).
#   These updates are based on semantic rules managed outside of the Terraform scope.

# ====================================================================================================
#  CLUSTER
# ====================================================================================================

# https://learn.hashicorp.com/tutorials/terraform/gke
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/using_gke_with_terraform

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster
resource "google_container_cluster" "cluster" {
  provider = google-beta

  name     = "${var.name}-cluster"
  project  = var.project
  location = var.region  # Regional (vs. zonal)

  # ========================================> NETWORKING <========================================

  # Public and private subnetworks both have outbound access to the Internet.
  # Public subnetwork is reachable from the Internet whereas the private one is not.
  network         = var.network.id
  subnetwork      = var.public_cluster ? var.public_subnetwork.id : var.private_subnetwork.id
  networking_mode = "VPC_NATIVE"  # VPC_NATIVE, ROUTES

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_ip_allocation_policy
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
    cluster_ipv4_cidr_block       = var.pods_secondary_range_name     == null ? "/16" : null
    services_ipv4_cidr_block      = var.services_secondary_range_name == null ? "/16" : null
  }

  # https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters#req_res_lim
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_private_cluster_config
  private_cluster_config {
    enable_private_nodes    = var.public_cluster ? false : true
    enable_private_endpoint = var.public_cluster ? false : true
    master_ipv4_cidr_block  = var.public_cluster ? null  : local.master_ipv4_cidr
  }

  # https://www.terraform.io/docs/language/expressions/dynamic-blocks.html
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_master_authorized_networks_config
  dynamic "master_authorized_networks_config" {
    for_each = var.public_cluster ? [] : [{
      cidr_block   = var.public_subnetwork.primary_cidr
      display_name = "Allow public subnetwork access"
    }]

    content {
      cidr_blocks {
        cidr_block   = master_authorized_networks_config.value.cidr_block
        display_name = master_authorized_networks_config.value.display_name
      }
    }
  }

  # https://kubernetes.io/docs/concepts/services-networking/network-policies
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_network_policy
  network_policy {
    enabled  = var.enable_network_policy
    provider = var.enable_network_policy ? "CALICO" : null
  }

  # ========================================> SCURITY <========================================

  enable_shielded_nodes       = true
  enable_binary_authorization = true

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_master_auth
  master_auth {
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#client_certificate_config
    client_certificate_config {
      issue_client_certificate = true
    }
  }

  # ========================================> VERSION MANAGEMENT <========================================

  # https://cloud.google.com/kubernetes-engine/docs/concepts/release-channels
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_release_channel
  release_channel {
    # UNSPECIFIED, STABLE, REGULAR, RAPID
    channel = var.release_channel
  }

  # ========================================> AUTOSCALING <========================================

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_cluster_autoscaling
  cluster_autoscaling {
    enabled             = var.cluster_autoscaling.enabled
    autoscaling_profile = "BALANCED"  # BALANCED, OPTIMIZE_UTILIZATION

    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_resource_limits
    resource_limits {
      resource_type = "cpu"
      minimum       = var.cluster_autoscaling.min_cpu_m * 1000 * 1000
      maximum       = var.cluster_autoscaling.max_cpu_m * 1000 * 1000
    }

    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_resource_limits
    resource_limits {
      resource_type = "memory"
      minimum       = var.cluster_autoscaling.min_memory_mi * 1024 *  1024
      maximum       = var.cluster_autoscaling.max_memory_mi * 1024 *  1024
    }

    # https://cloud.google.com/kubernetes-engine/docs/how-to/node-auto-provisioning
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_auto_provisioning_defaults
    auto_provisioning_defaults {
      service_account = google_service_account.cluster.email
      oauth_scopes = [ "https://www.googleapis.com/auth/cloud-platform" ]
    }
  }

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_vertical_pod_autoscaling
  vertical_pod_autoscaling {
    enabled = var.enable_vertical_pod_autoscaling
  }

  # ========================================> MONITORING <========================================

  logging_service    = var.enable_stackdriver_logging    ? "logging.googleapis.com/kubernetes"    : "none"
  monitoring_service = var.enable_stackdriver_monitoring ? "monitoring.googleapis.com/kubernetes" : "none"

  # ========================================> NOTIFICATION <========================================

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_notification_config
  notification_config {
    pubsub {
      enabled = var.notification_topic_id != null
      topic   = var.notification_topic_id
    }
  }

  # ========================================> ADDONS <========================================

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_addons_config
  addons_config {
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#network_policy_config
    network_policy_config {
      disabled = !var.enable_network_policy
    }

    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#horizontal_pod_autoscaling
    horizontal_pod_autoscaling {
      disabled = !var.enable_horizontal_pod_autoscaling
    }

    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#http_load_balancing
    http_load_balancing {
      disabled = true
    }

    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_cloudrun_config
    cloudrun_config {
      disabled = true
    }

    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_istio_config
    istio_config {
      disabled = true
    }
  }

  # ====================================================================================================

  # We cannot create a cluster with no node pool, but we want to only use separately managed node pools.
  # So, we create the smallest possible default node pool and immediately delete it.
  initial_node_count       = 1
  remove_default_node_pool = true

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#timeouts
  timeouts {
    create = var.timeouts.create
    read   = var.timeouts.read
    update = var.timeouts.update
    delete = var.timeouts.delete
  }

  resource_labels = merge(var.cluster_labels, {
    name = format("%s-cluster", var.name)
  })

  lifecycle {
    ignore_changes = [
      node_pool,
      initial_node_count,
      resource_labels,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones
data "google_compute_zones" "available" {
  project = var.project
  region  = var.region
}
