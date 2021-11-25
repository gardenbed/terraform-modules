variable "uuid" {
  type = string
}

variable "owner" {
  type = string
}

variable "git_repo" {
  type    = string
  default = "https://github.com/gardenbed/terraform-modules/tree/main/test/aws"
}

variable "git_branch" {
  type = string
}

variable "git_commit" {
  type = string
}

module "metadata" {
  source = "../../aws/metadata"

  uuid       = var.uuid
  owner      = var.owner
  git_repo   = var.git_repo
  git_branch = var.git_branch
  git_commit = var.git_commit
}
