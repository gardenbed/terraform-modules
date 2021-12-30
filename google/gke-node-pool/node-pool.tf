# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#create_before_destroy
# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#ignore_changes
#   We ignore changes to labels since they can take new values on each run (terraform plan/apply).
#   These updates are based on semantic rules managed outside of the Terraform scope.

# ====================================================================================================
#  NODE POOL
# ====================================================================================================

# https://learn.hashicorp.com/tutorials/terraform/gke
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/using_gke_with_terraform

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool
resource "google_container_node_pool" "node_pool" {
  provider = google-beta

  name               = "${var.name}-node-pool"
  project            = var.project
  location           = var.region
  cluster            = var.cluster_id
  node_locations     = data.google_compute_zones.available.names
  initial_node_count = var.initial_node_count

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool#nested_management
  management { 
    auto_repair  = true
    auto_upgrade = var.upgrade.auto
  }

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool#nested_upgrade_settings
  upgrade_settings {
    max_surge       = var.upgrade.max_surge
    max_unavailable = var.upgrade.max_unavailable
  }

  # https://www.terraform.io/docs/language/expressions/dynamic-blocks.html
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool#nested_autoscaling
  dynamic "autoscaling" {
    for_each = var.autoscaling.enabled ? [{
      min_node_count = var.autoscaling.min_node_count
      max_node_count = var.autoscaling.max_node_count
    }] : []

    content {
      min_node_count = autoscaling.value.min_node_count
      max_node_count = autoscaling.value.max_node_count
    }
  }

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_network_config

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_node_config
  node_config {
    service_account = var.service_account_email
    spot            = var.nodes.spot
    preemptible     = var.nodes.preemptible
    image_type      = var.nodes.image_type
    machine_type    = var.nodes.machine_type
    disk_type       = var.nodes.disk_type
    disk_size_gb    = var.nodes.disk_size_gb

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_shielded_instance_config
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    # https://www.terraform.io/docs/language/expressions/dynamic-blocks.html
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_sandbox_config
    dynamic "sandbox_config" {
      for_each = var.nodes.enable_gvisor ? [ "gvisor" ] : []

      content {
        sandbox_type = sandbox_config.value
      }
    }

    # https://www.terraform.io/docs/language/expressions/dynamic-blocks.html
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_taint
    dynamic "taint" {
      for_each = var.node_taints

      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    } 

    metadata = merge(var.nodes.metadata,
      {
        disable-legacy-endpoints = true,
      },
      var.ssh == null ? {} : {
        ssh-keys = format(
          "admin:%s",
          file(var.ssh.node_pool_public_key_file),
        ),
      }
    )

    tags = concat(var.nodes.tags, [
      "gke-node",
      var.name,
      var.network_tag,
    ])

    labels = merge(var.nodes.labels, {
      name = format("%s-node-pool", var.name)
    })
  }

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool#timeouts
  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }

  lifecycle {
    ignore_changes = [
      initial_node_count,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones
data "google_compute_zones" "available" {
  project = var.project
  region  = var.region
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_instance_group
data "google_compute_instance_group" "node_pool" {
  # The google_container_node_pool.node_pool.managed_instance_group_urls cannot be determined until apply.
  # So, Terraform cannot predict how many instances will be created.
  # We use the number of zones as a proxy for the number of instance groups in the node pool.
  count = local.zone_count

  project   = var.project
  self_link = google_container_node_pool.node_pool.managed_instance_group_urls[count.index]
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_instance
data "google_compute_instance" "instances" {
  # The data.google_compute_instance_group.node_pool.instances  cannot be determined until apply.
  # So, Terraform cannot predict how many instances will be created.
  # We use the combination of number of zones multiplied by the initial number of nodes as a proxy for the number of instances in the node pool.
  count = local.total_node_count

  project   = var.project
  self_link = element(
    flatten(data.google_compute_instance_group.node_pool.*.instances),
    count.index,
  )
}
