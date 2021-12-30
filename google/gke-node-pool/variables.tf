# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "name" {
  description = "A human-readable name for the node pool resources."
  type        = string
  nullable    = false
}

variable "project" {
  description = "A Google Cloud project to manage node pool resources in."
  type        = string
  nullable    = false
}

variable "region" {
  description = "A Google Cloud region to manage node pool resources in."
  type        = string
  nullable    = false
}

# ==================================================< NODE POOL >==================================================

variable "cluster_id" {
  description = "The cluster ID for the node pool."
  type        = string
  nullable    = false
}

variable "service_account_email" {
  description = "The service account email for the node pool."
  type        = string
  nullable    = false
}

variable "network_tag" {
  description = "The network tag for the node pool."
  type        = string
  nullable    = false
}

variable "initial_node_count" {
  description = "The initial number of nodes in each zone."
  type        = number
  nullable    = false
  default     = 1
}

variable "autoscaling" {
  description = "Autoscaling settings for the node pool."
  type = object({
    enabled        = bool
    min_node_count = number
    max_node_count = number
  })
  nullable = false
  default = {
    enabled        = true
    min_node_count = 1
    max_node_count = 10
  }
}

variable "upgrade" {
  description = "Upgrade settings for the node pool."
  type = object({
    auto            = bool
    max_surge       = number
    max_unavailable = number
  })
  nullable = false
  default = {
    auto            = true
    max_surge       = 1
    max_unavailable = 1
  }
}

variable "nodes" {
  description = "Configurations for the nodes in the node pool."
  type = object({
    spot          = bool
    preemptible   = bool
    enable_gvisor = bool
    image_type    = string
    machine_type  = string
    disk_type     = string
    disk_size_gb  = number
    metadata      = map(string)
    tags          = list(string)
    labels        = map(string)
  })
  nullable = false
  default = {
    spot          = false
    preemptible   = false
    enable_gvisor = false
    image_type    = "cos_containerd"
    machine_type  = "e2-medium"
    disk_type     = "pd-standard"
    disk_size_gb  = 100
    metadata      = {}
    tags          = []
    labels        = {}
  }
}

variable "node_taints" {
  description = "A list of Kubernetes taints for the nodes in the node pool."
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  nullable = false
  default = []
}

# ==================================================< SSH >==================================================

variable "ssh" {
  description = "An object containing information required for enabling SSH access to node pool."
  type = object({
    node_pool_public_key_file = string
  })
  default = null
}

variable "ssh_config_file" {
  description = "An object containing information required for writting the SSH config file."
  type = object({
    bastion_address            = string
    bastion_private_key_file   = string
    node_pool_cidr             = string
    node_pool_private_key_file = string
  })
  default = null
}

# ==================================================< TIMEOUTS >==================================================

variable "timeouts" {
  description = "The timeout values for the node pool operations."
  type = object({
    create = string
    update = string
    delete = string
  })
  nullable = false
  default = {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}
