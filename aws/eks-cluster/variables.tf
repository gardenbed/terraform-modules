# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "name" {
  description = "A human-readable name for the cluster."
  type        = string
  nullable    = false
}

variable "region" {
  description = "The AWS region for the cluster."
  type        = string
  nullable    = false
}

# ==================================================< CLUSTER >==================================================

variable "cluster_version" {
  description = "Kubernetes minor version to use for the cluster (e.g. 1.22)."
  type        = string
  default     = null
}

variable "enable_iam_role_service_account" {
  description = "Whether or not to enable IAM Roles for Service Accounts."
  type        = bool
  nullable    = false
  default     = false
}

# ==================================================< NETWORK >==================================================

variable "vpc_id" {
  description = "The VPC network ID for the cluster."
  type        = string
  nullable    = false
}

variable "subnet_ids" {
  description = "The list of subnet IDs for placing the cluster within."
  type        = set(string)
  nullable    = false
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#kubernetes_network_config
variable "cluster_service_ipv4_cidr" {
  description = "The IPv4 CIDR block for the cluster service addresses."
  type        = string
  nullable    = false
  default     = "10.100.0.0/16"
}

variable "public_api_cidrs" {
  description = "A list of trusted CIDR blocks that can access the cluster public API server endpoint."
  type        = set(string)
  nullable    = false
  default     = [ "0.0.0.0/0" ]
}

variable "cluster_egress_cidrs" {
  description = "A list of trusted CIDR blocks that are permitted for the cluster egress traffic."
  type        = set(string)
  nullable    = false
  default     = [ "0.0.0.0/0" ]
}

# ==================================================< LOGGING >==================================================


variable "enable_cluster_logs" {
  description = "Whether or not to enable logging for the cluster control plane."
  type        = bool
  nullable    = false
  default     = false
}

variable "logs_retention_days" {
  description = "The number of days to retain the cluster logs."
  type        = number
  nullable    = false
  default     = 60
}

# ==================================================< TIMEOUTS >==================================================

variable "timeouts" {
  description = "The timeout values for the cluster operations."
  type = object({
    create = string
    update = string
    delete = string
  })
  nullable = false
  default = {
    create = "30m"
    update = "60m"
    delete = "15m"
  }
}

# ==================================================< TAGS >==================================================

variable "common_tags" {
  description = "A map of common tags for the resources."
  type        = map(string)
  default     = null
}

variable "cluster_tags" {
  description = "A map of tags to be applied to the cluster."
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
