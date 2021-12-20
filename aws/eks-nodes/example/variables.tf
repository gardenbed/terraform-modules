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

variable "bastion_public_key_file" {
  type = string
}

variable "bastion_private_key_file" {
  type = string
}

variable "nodes_public_key_file" {
  type = string
}

variable "nodes_private_key_file" {
  type = string
}
