variable "access_key" {
  type      = string
  sensitive = true
}

variable "secret_key" {
  type      = string
  sensitive = true
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "ssh_path" {
  type = string
}

variable "bastion_public_key" {
  type = string
}

variable "bastion_private_key" {
  type = string
}

variable "nodes_public_key" {
  type = string
}

variable "nodes_private_key" {
  type = string
}
