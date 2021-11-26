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

variable "bastion_public_key" {
  type = string
}
