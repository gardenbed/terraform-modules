# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "name" {
  description = "A human-readable name for the node group."
  type        = string
  nullable    = false
}

# ==================================================< NODE GROUP >==================================================

variable "cluster_name" {
  description = "The name of the cluster for the node group."
  type        = string
  nullable    = false
}

# ==================================================< NETWORK >==================================================

variable "subnets" {
  description = "The list of private subnet objects for placing the node group within."
  type = list(object({
    id                = string
    cidr              = string
    availability_zone = string
  }))
  nullable = false
}

# ==================================================< SSH >==================================================

variable "ssh" {
  description = "An object containing information required for enabling SSH access to node group."
  type = object({
    bastion_security_group_id  = string
    node_group_public_key_file = string
  })
  nullable = false
}

variable "ssh_config_file" {
  description = "An object containing information required for writting the SSH config file."
  type = object({
    bastion_address             = string
    bastion_private_key_file    = string
    node_group_private_key_file = string
  })
  nullable = false
}

# ==================================================< SPEC >==================================================

variable "profile" {
  description = "The configuration parameters for the node group."
  type = object({
    capacity_type              = string # "ON_DEMAND", "SPOT"
    instance_types             = list(string)
    disk_size_gb               = number
    min_node_size              = number
    desired_node_size          = number
    max_node_size              = number
    max_unavailable            = number
    max_unavailable_percentage = number
    create_timeout             = string
    update_timeout             = string
    delete_timeout             = string
  })
  nullable = false
  default = {
    capacity_type              = "ON_DEMAND"
    instance_types             = [ "t2.micro" ]
    disk_size_gb               = 32
    min_node_size              = 1
    desired_node_size          = 3
    max_node_size              = 5
    max_unavailable            = 2
    max_unavailable_percentage = null
    create_timeout             = "60m"
    update_timeout             = "60m"
    delete_timeout             = "60m"
  }
}

variable "taints" {
  description = "A list of Kubernetes taints to be applied to the nodes in the node group."
  type = list(object({
    key    = string # maximum length of 63
    value  = string # maximum length of 63
    effect = string # "NO_SCHEDULE", "NO_EXECUTE", "PREFER_NO_SCHEDULE"
  }))
  nullable = false
  default = []
}

variable "labels" {
  description = "A key-value map of Kubernetes labels to be applied to the nodes in the node group."
  type        = map(string)
  default     = null
}

# ==================================================< TAGS >==================================================

variable "common_tags" {
  description = "A map of common tags for the resources."
  type        = map(string)
  default     = null
}
