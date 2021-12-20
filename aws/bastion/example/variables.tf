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

variable "ssh_public_key_file" {
  type = string
}

variable "ssh_private_key_file" {
  type = string
}
