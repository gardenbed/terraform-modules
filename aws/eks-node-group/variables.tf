# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "name" {
  description = "A human-readable name for the node group."
  type        = string
}

# ==================================================< NODE GROUP >==================================================

variable "cluster_name" {
  description = "The name of the cluster for the node group."
  type        = string
}

# ==================================================< NETWORK >==================================================

variable "subnets" {
  description = "The list of private subnet objects for placing the node group within."
  type = list(object({
    id                = string
    cidr              = string
    availability_zone = string
  }))
}

# ==================================================< SSH >==================================================

variable "bastion" {
  description = "An object containing information about the bastion hosts."
  type = object({
    security_group_id = string
    dns_name          = string
    private_key_file  = string
  })
}

variable "ssh" {
  description = "An object containing information for ssh access to the node group."
  type = object({
    path             = string
    private_key_file = string
    public_key_file  = string
  })
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

variable "labels" {
  description = "A key-value map of Kubernetes labels to be applied to the nodes in the node group."
  type        = map(string)
  default     = {}
}

variable "taints" {
  description = "A list of Kubernetes taints to be applied to the nodes in the node group."
  type = list(object({
    key    = string # maximum length of 63
    value  = string # maximum length of 63
    effect = string # "NO_SCHEDULE", "NO_EXECUTE", "PREFER_NO_SCHEDULE"
  }))
  default = []
}

# ==================================================< TAGS >==================================================

variable "common_tags" {
  description = "A map of common tags for the resources."
  type        = map(string)
  default     = {}
}
