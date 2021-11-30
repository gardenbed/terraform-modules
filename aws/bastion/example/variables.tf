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

variable "private_key_file" {
  type = string
}

variable "public_key_file" {
  type = string
}
