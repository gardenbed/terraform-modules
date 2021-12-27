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

variable "network" {
  description = "The VPC network information."
  type = object({
    id = string
  })
  nullable = false
}

variable "public_subnetwork" {
  description = "The VPC public subnetwork information."
  type = object({
    id          = string
    network_tag = string
  })
  nullable = false
}

# ==================================================< INSTANCE >==================================================

variable "machine_type" {
  description = "The Google Cloud machine type for the bastion instances."
  type        = string
  nullable    = false
  default     = "e2-micro"
}

variable "size" {
  description = "The number of bastion instances."
  type        = number
  nullable    = false
  default     = 1
}

# ==================================================< OS LOGINS >==================================================

variable "enable_os_login" {
  description = "Whether or not to enable OS Login for accessing the bastion instances."
  type        = bool
  nullable    = false
  default     = true
}

variable "members" {
  description = "A list of IAM identities allowed accessing to the bastion instances."
  type        = set(string)
  nullable    = false
  default     = [ "allAuthenticatedUsers" ]
}

# ==================================================< SSH KEYS >==================================================

variable "enable_ssh_keys" {
  description = "Whether or not to enable SSH keys for accessing the bastion instances."
  type        = bool
  nullable    = false
  default     = false
}

variable "ssh_public_key_file" {
  description = "The path to public key file for SSH access to bastion instances. This is only required if enable_ssh_keys is true."
  type        = string
  default     = null
}

variable "ssh_config_file" {
  description = "If set, an SSH config file will be written next to the private key file."
  type = object({
    private_key_file = string
  })
  default = null
}

# ==================================================< TAGS >==================================================

variable "network_tags" {
  description = "A list of network tags for the resources."
  type        = list(string)
  nullable    = false
  default     = []
}

# ==================================================< LABELS >==================================================

variable "common_labels" {
  description = "A map of common labels for the resources."
  type        = map(string)
  default     = null
}
