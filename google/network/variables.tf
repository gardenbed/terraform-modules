# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "name" {
  description = "A human-readable name for the deployment resources."
  type        = string
  nullable    = false
}

variable "project" {
  description = "A Google Cloud project to manage deployment resources in."
  type        = string
  nullable    = false
}

variable "region" {
  description = "A Google Cloud region to manage deployment resources in."
  type        = string
  nullable    = false
}

# ==================================================< NETWORK >==================================================

# https://en.wikipedia.org/wiki/Classful_network
# https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing
variable "vpc_cidrs" {
  description = "VPC CIDR for each Google Cloud region."
  type = map(string)
  nullable = false
  default = {
    asia-east1              = "10.8.0.0/13"
    asia-east2              = "10.16.0.0/13"
    asia-northeast1         = "10.24.0.0/13"
    asia-northeast2         = "10.32.0.0/13"
    asia-northeast3         = "10.40.0.0/13"
    asia-south1             = "10.48.0.0/13"
    asia-south2             = "10.56.0.0/13"
    asia-southeast1         = "10.64.0.0/13"
    asia-southeast2         = "10.72.0.0/13"
    australia-southeast1    = "10.80.0.0/13"
    australia-southeast2    = "10.88.0.0/13"
    europe-central2         = "10.96.0.0/13"
    europe-north1           = "10.104.0.0/13"
    europe-west1            = "10.112.0.0/13"
    europe-west2            = "10.120.0.0/13"
    europe-west3            = "10.128.0.0/13"
    europe-west4            = "10.136.0.0/13"
    europe-west6            = "10.144.0.0/13"
    northamerica-northeast1 = "10.152.0.0/13"
    northamerica-northeast2 = "10.160.0.0/13"
    southamerica-east1      = "10.168.0.0/13"
    southamerica-west1      = "10.176.0.0/13"
    us-central1             = "10.184.0.0/13"
    us-east1                = "10.192.0.0/13"
    us-east4                = "10.200.0.0/13"
    us-west1                = "10.208.0.0/13"
    us-west2                = "10.216.0.0/13"
    us-west3                = "10.224.0.0/13"
    us-west4                = "10.232.0.0/13"
  }
}

variable "public_secondary_ranges" {
  description = "A set of names for the public subnetwork secondary IP ranges. The CIDR blocks are determined automatically."
  type        = list(string)
  nullable    = false
  default     = []
}

variable "private_secondary_ranges" {
  description = "A set of names for the private subnetwork secondary IP ranges. The CIDR blocks are determined automatically."
  type        = list(string)
  nullable    = false
  default     = []
}

# ==================================================< FIREWALL >==================================================

variable "public_outgoing_cidrs" {
  description = "A list of trusted CIDR blocks for public subnetwork outgoing traffic."
  type        = list(string)
  nullable    = false
  default     = [ "0.0.0.0/0" ]
}

variable "private_outgoing_cidrs" {
  description = "A list of trusted CIDR blocks for public subnetwork outgoing traffic."
  type        = list(string)
  nullable    = false
  default     = [ "0.0.0.0/0" ]
}

variable "icmp_incoming_cidrs" {
  description = "A list of trusted CIDR blocks for public subnetwork incoming traffic."
  type        = list(string)
  nullable    = false
  default     = [ "0.0.0.0/0" ]
}

variable "ssh_incoming_cidrs" {
  description = "A list of trusted CIDR blocks for public subnetwork incoming traffic."
  type        = list(string)
  nullable    = false
  default     = [ "0.0.0.0/0" ]
}

# ==================================================< LOGGING >==================================================

variable "flow_log_sampling_rate" {
  description = "The sampling rate for the VPC flow logs."
  type        = number
  nullable    = false
  default     = 0.0

  validation {
    condition     = var.flow_log_sampling_rate >= 0.0 && var.flow_log_sampling_rate <= 1.0
    error_message = "The sampling rate must be between 0 and 1."
  }
}
