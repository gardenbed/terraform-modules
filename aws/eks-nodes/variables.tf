# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "name" {
  description = "A human-readable name for the nodes."
  type        = string
  nullable    = false
}

# ==================================================< NODE GROUP >==================================================

variable "cluster_name" {
  description = "The name of the cluster for the nodes."
  type        = string
  nullable    = false
}

variable "cluster_additional_security_group_id" {
  description = "The additional security group ID of the cluster for the nodes."
  type        = string
  nullable    = false
}

# ==================================================< NETWORK >==================================================

variable "subnet_cidrs" {
  description = "The list of private subnet CIDR blocks."
  type        = list(string)
  nullable    = false
}

variable "nodes_egress_cidrs" {
  description = "A list of trusted CIDR blocks that are permitted for the nodes egress traffic."
  type        = set(string)
  nullable    = false
  default     = [ "0.0.0.0/0" ]
}

# ==================================================< SSH >==================================================

variable "ssh" {
  description = "An object containing information required for enabling SSH access to nodes."
  type = object({
    bastion_security_group_id = string
    nodes_public_key_file     = string
  })
  nullable = false
}

variable "ssh_config_file" {
  description = "An object containing information required for writting the SSH config file."
  type = object({
    bastion_address          = string
    bastion_private_key_file = string
    nodes_private_key_file   = string
  })
  nullable = false
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
  nullable = false
  default = {
    instance_type    = "t2.micro"
    volume_size_gb   = 32
    min_size         = 1
    desired_capacity = 3
    max_size         = 5
  }
}

# ==================================================< TAGS >==================================================

variable "common_tags" {
  description = "A map of common tags for the resources."
  type        = map(string)
  default     = null
}
