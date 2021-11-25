# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "uuid" {
  type        = string
  description = "A universally unique identifier for the deployment."
}

variable "owner" {
  type        = string
  description = "An identifiable name, username, email, or uuid that owns the deployment."
}

variable "git_repo" {
  type        = string
  description = "The git repository address for the deployment."
}

variable "git_branch" {
  type        = string
  description = "The git branch name for the deployment."
}

variable "git_commit" {
  type        = string
  description = "The git commit hash for the deployment."
}
