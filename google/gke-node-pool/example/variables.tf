variable "credentials_file" {
  type    = string
  default = "../../account.json"
}

variable "name" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "kubeconfig_path" {
  type    = string
  default = "."
}

variable "bastion_private_key_file" {
  type = string
}

variable "bastion_public_key_file" {
  type = string
}

variable "node_pool_private_key_file" {
  type = string
}

variable "node_pool_public_key_file" {
  type = string
}
