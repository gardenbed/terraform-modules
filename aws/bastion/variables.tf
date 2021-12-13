# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "name" {
  description = "The name of the deployment."
  type        = string
}

variable "region" {
  description = "The AWS region of the deployment."
  type        = string
}

# ==================================================< NETWORKING >==================================================

variable "vpc" {
  description = "The VPC network information."
  type = object({
    id   = string
    cidr = string
  })
}

variable "public_subnets" {
  description = "The public subnets information."
  type = list(object({
    id   = string
    cidr = string
  }))
}

# ==================================================< BASTION >==================================================

variable "instance_type" {
  description = "The AWS EC2 instance type for bastion hosts."
  type        = string
  default     = "t2.micro"
}

variable "ssh_cidrs" {
  description = "A set of trusted CIDR blocks for incoming traffic to bastion hosts."
  type        = set(string)
  default     = [ "0.0.0.0/0" ]
}

variable "ssh_path" {
  description = "The path to a directory for SSH config file."
  type        = string
  default     = null
}

variable "private_key_file" {
  description = "The path to the SSH private key file for bastion hosts."
  type        = string
  default     = null
}

variable "public_key_file" {
  description = "The path to the SSH public key file for bastion hosts."
  type        = string
}

# ==================================================< TAGS >==================================================

variable "common_tags" {
  description = "A map of common tags for the resources."
  type        = map(string)
  default     = {}
}
