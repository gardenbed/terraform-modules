variable "uuid" {
  type = string
}

variable "owner" {
  type = string
}

variable "git_repo" {
  type    = string
  default = "https://github.com/gardenbed/terraform-modules"
}

variable "git_branch" {
  type = string
}

variable "git_commit" {
  type = string
}
