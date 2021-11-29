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

variable "bastion_private_key_file" {
  type = string
}

variable "bastion_public_key_file" {
  type = string
}

variable "node_group_private_key_file" {
  type = string
}

variable "node_group_public_key_file" {
  type = string
}
