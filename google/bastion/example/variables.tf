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

variable "ssh_public_key_file" {
  type = string
}

variable "ssh_private_key_file" {
  type = string
}
