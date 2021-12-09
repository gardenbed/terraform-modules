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

# ==================================================< NETWORK >==================================================

variable "network" {
  description = "The VPC network information."
  type = object({
    id = string
  })
}

variable "public_subnetwork" {
  description = "The VPC public subnetwork information."
  type = object({
    id          = string
    network_tag = string
  })
}

# ==================================================< INSTANCE >==================================================

variable "machine_type" {
  description = "The Google Cloud machine type for the bastion instances."
  type        = string
  default     = "e2-small"
}

# ==================================================< OS LOGINS >==================================================

variable "enable_os_login" {
  description = "Whether or not to enable OS Login for accessing the bastion instances."
  type        = bool
  default     = true
}

variable "members" {
  description = "A list of IAM identities allowed accessing to the bastion instances."
  type        = set(string)
  default     = [ "allAuthenticatedUsers" ]
}

# ==================================================< SSH KEYS >==================================================

variable "enable_ssh_keys" {
  description = "Whether or not to enable SSH keys for accessing the bastion instances."
  type        = bool
  default     = false
}

variable "ssh_path" {
  description = "The path to a directory for SSH config file."
  type        = string
  default     = null
}

variable "ssh_private_key_file" {
  description = "The path to the SSH private key file for bastion hosts."
  type        = string
  default     = null
}

variable "ssh_public_key_file" {
  description = "The path to the SSH public key file for accessing the bastion instances."
  type        = string
  default     = null
}

# ==================================================< TAGS >==================================================

variable "network_tags" {
  description = "A list of network tags for the resources."
  type        = list(string)
  default     = []
}

# ==================================================< LABELS >==================================================

variable "common_labels" {
  description = "A map of common labels for the resources."
  type        = map(string)
  default     = {}
}
