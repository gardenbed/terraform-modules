# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "name" {
  description = "The name of the deployment."
  type        = string
  nullable    = false
}

variable "region" {
  description = "The AWS region of the deployment."
  type        = string
  nullable    = false
}

# ==================================================< NETWORKING >==================================================

variable "vpc" {
  description = "The VPC network information."
  type = object({
    id   = string
    cidr = string
  })
  nullable = false
}

variable "public_subnets" {
  description = "The public subnets information."
  type = list(object({
    id   = string
    cidr = string
  }))
  nullable = false
}

# ==================================================< BASTION >==================================================

variable "instance_type" {
  description = "The AWS EC2 instance type for bastion hosts."
  type        = string
  nullable    = false
  default     = "t2.micro"
}

variable "ssh_cidrs" {
  description = "A set of trusted CIDR blocks for incoming traffic to bastion hosts."
  type        = set(string)
  nullable    = false
  default     = [ "0.0.0.0/0" ]
}

variable "ssh_public_key_file" {
  description = "The path to public key file for SSH access to bastion hosts."
  type        = string
  nullable    = false
}

variable "ssh_config_file" {
  description = "If set, an SSH config file will be written next to the private key file."
  type = object({
    private_key_file = string
  })
  default = null
}

# ==================================================< TAGS >==================================================

variable "common_tags" {
  description = "A map of common tags for the resources."
  type        = map(string)
  default     = null
}
