# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "name" {
  description = "A human-readable name for the deployment resources."
  type        = string
}

variable "project" {
  description = "A Google Cloud project to manage deployment resources in."
  type        = string
}

variable "region" {
  description = "A Google Cloud region to manage deployment resources in."
  type        = string
}

# ==================================================< NETWORKING >==================================================

# https://en.wikipedia.org/wiki/Classful_network
# https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing
variable "vpc_cidrs" {
  description = "VPC CIDR for each Google Cloud region."
  type = map(string)
  default = {
    asia-east1              = "10.10.0.0/16"
    asia-east2              = "10.11.0.0/16"
    asia-northeast1         = "10.12.0.0/16"
    asia-northeast2         = "10.13.0.0/16"
    asia-northeast3         = "10.14.0.0/16"
    asia-south1             = "10.15.0.0/16"
    asia-south2             = "10.16.0.0/16"
    asia-southeast1         = "10.17.0.0/16"
    asia-southeast2         = "10.18.0.0/16"
    australia-southeast1    = "10.19.0.0/16"
    australia-southeast2    = "10.20.0.0/16"
    europe-central2         = "10.21.0.0/16"
    europe-north1           = "10.22.0.0/16"
    europe-west1            = "10.23.0.0/16"
    europe-west2            = "10.24.0.0/16"
    europe-west3            = "10.25.0.0/16"
    europe-west4            = "10.26.0.0/16"
    europe-west6            = "10.27.0.0/16"
    northamerica-northeast1 = "10.28.0.0/16"
    northamerica-northeast2 = "10.29.0.0/16"
    southamerica-east1      = "10.30.0.0/16"
    southamerica-west1      = "10.31.0.0/16"
    us-central1             = "10.32.0.0/16"
    us-east1                = "10.33.0.0/16"
    us-east4                = "10.34.0.0/16"
    us-west1                = "10.35.0.0/16"
    us-west2                = "10.36.0.0/16"
    us-west3                = "10.37.0.0/16"
    us-west4                = "10.38.0.0/16"
  }
}

variable "public_incoming_cidrs" {
  description = "A list of trusted CIDR blocks for public subnetwork incoming traffic."
  type        = set(string)
  default     = [ "0.0.0.0/0" ]
}

variable "public_outgoing_cidrs" {
  description = "A list of trusted CIDR blocks for public subnetwork outgoing traffic."
  type        = set(string)
  default     = [ "0.0.0.0/0" ]
}

variable "private_outgoing_cidrs" {
  description = "A list of trusted CIDR blocks for public subnetwork outgoing traffic."
  type        = set(string)
  default     = [ "0.0.0.0/0" ]
}

# ==================================================< LOGGING >==================================================

variable "flow_log_sampling_rate" {
  description = "The sampling rate for the VPC flow logs."
  type       = number
  default    = 0.0

  validation {
    condition     = var.flow_log_sampling_rate >= 0.0 && var.flow_log_sampling_rate <= 1.0
    error_message = "The sampling rate must be between 0 and 1."
  }
}
