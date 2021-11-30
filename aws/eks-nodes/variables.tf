# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "name" {
  description = "A human-readable name for the nodes."
  type        = string
}

# ==================================================< NODE GROUP >==================================================

variable "cluster_name" {
  description = "The name of the cluster for the nodes."
  type        = string
}

variable "cluster_additional_security_group_id" {
  description = "The additional security group ID of the cluster for the nodes."
  type        = string
}

# ==================================================< NETWORK >==================================================

variable "subnet_cidrs" {
  description = "The list of private subnet CIDR blocks."
  type        = list(string)
}

variable "nodes_egress_cidrs" {
  description = "A list of trusted CIDR blocks that are permitted for the nodes egress traffic."
  type        = set(string)
  default     = [ "0.0.0.0/0" ]
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
  description = "An object containing information for ssh access to the nodes."
  type = object({
    ssh_path         = string
    private_key_file = string
    public_key_file  = string
  })
}

# ==================================================< SPEC >==================================================

variable "profile" {
  description = "The configuration parameters for the nodes."
  type = object({
    instance_type    = string
    volume_size_gb   = number
    min_size         = number
    desired_capacity = number
    max_size         = number
  })
  default = {
    instance_type    = "t2.micro"
    volume_size_gb   = 32
    min_size         = 1
    desired_capacity = 3
    max_size         = 5
  }
}

variable "labels" {
  description = "A key-value map of Kubernetes labels to be applied to the nodes."
  type        = map(string)
  default     = {}
}

variable "taints" {
  description = "A list of Kubernetes taints to be applied to the nodes."
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
