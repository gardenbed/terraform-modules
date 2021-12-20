# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "name" {
  description = "A human-readable name for the cluster resources."
  type        = string
  nullable    = false
}

variable "project" {
  description = "A Google Cloud project to manage cluster resources in."
  type        = string
  nullable    = false
}

variable "region" {
  description = "A Google Cloud region to manage cluster resources in."
  type        = string
  nullable    = false
}

# ==================================================< CLUSTER >==================================================

variable "public_cluster" {
  description = "Determines if the cluser is public or private."
  type        = bool
  nullable    = false
  default     = false
}

variable "release_channel" {
  description = "The GKE release channel for Kubernetes version."
  type        = string
  nullable    = false
  default     = "STABLE"

  validation {
    condition     = contains([ "UNSPECIFIED", "STABLE", "REGULAR", "RAPID" ], var.release_channel)
    error_message = "The release channel can be only one of UNSPECIFIED, STABLE, REGULAR, or RAPID."
  }
}

# ==================================================< NETWORK >==================================================

variable "network" {
  description = "The VPC network information."
  type = object({
    id = string
  })
  nullable = false
}

variable "public_subnetwork" {
  description = "The VPC public subnetwork information. This has to be specified if public_cluster is true."
  type = object({
    id           = string
    primary_cidr = string
  })
}

variable "private_subnetwork" {
  description = "The VPC private subnetwork information. This has to be specified if public_cluster is false."
  type = object({
    id           = string
    primary_cidr = string
  })
}

variable "pods_secondary_range_name" {
  description = "The name of the secondary range in subnetworks for pods IP addresses."
  type        = string
  default     = null
}

variable "services_secondary_range_name" {
  description = "The name of the secondary range in subnetworks for services IP addresses."
  type        = string
  default     = null
}

variable "enable_network_policy" {
  description = "Whether or not to enable the network policy to control traffic flow at the IP address or port level (L3/L4)."
  type        = bool
  nullable    = false
  default     = false
}

# ==================================================< AUTOSCALING >==================================================

variable "cluster_autoscaling" {
  description = "The configurations for cluster autoscaling which automatically adjust the size of the cluster and node pools."
  type = object({
    enabled       = bool
    min_cpu_m     = number
    max_cpu_m     = number
    min_memory_mi = number
    max_memory_mi = number
  })
  nullable = false
  default = {
    enabled       = true
    min_cpu_m     = 250
    max_cpu_m     = 500
    min_memory_mi = 128
    max_memory_mi = 512
  }
}

variable "enable_vertical_pod_autoscaling" {
  description = "Whether or not to enable vertical pod autoscaling which automatically adjusts the resources for pods."
  type        = bool
  nullable    = false
  default     = true
}

variable "enable_horizontal_pod_autoscaling" {
  description = "Whether or not to enable horizontal pod autoscaling which increases or decreases the number of replicas."
  type        = bool
  nullable    = false
  default     = true
}

# ==================================================< MONITORING >==================================================

variable "enable_stackdriver_logging" {
  description = "Whether or not to enable the Stackdriver Kubernetes Engine Logging."
  type        = bool
  nullable    = false
  default     = true
}

variable "enable_stackdriver_monitoring" {
  description = "Whether or not to enable the Stackdriver Kubernetes Engine Monitoring."
  type        = bool
  nullable    = false
  default     = true
}

# ==================================================< NOTIFICATION >==================================================

variable "notification_topic_id" {
  description = "The Google Pub/Sub topic ID for sending the cluster notifications to."
  type        = string
  default     = null
}

# ==================================================< TIMEOUTS >==================================================

variable "timeouts" {
  description = "The timeout values for the cluster operations."
  type = object({
    create = string
    read   = string
    update = string
    delete = string
  })
  nullable = false
  default = {
    create = "30m"
    read   = "30m"
    update = "60m"
    delete = "60m"
  }
}

# ==================================================< LABELS >==================================================

variable "cluster_labels" {
  description = "A map of labels for the cluster resources."
  type        = map(string)
  default     = null
}

# ==================================================< MISC >==================================================

variable "kubeconfig_path" {
  description = "The path for writing the cluster kubeconfig file."
  type        = string
  nullable    = false
  default     = "."
}
