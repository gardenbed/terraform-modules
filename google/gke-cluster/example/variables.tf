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
