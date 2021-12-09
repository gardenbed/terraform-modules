# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "uuid" {
  description = "A universally unique identifier for the deployment."
  type        = string
}

variable "owner" {
  description = "An identifiable name, username, email, or uuid that owns the deployment."
  type        = string
}

variable "git_repo" {
  description = "The git repository address for the deployment."
  type        = string
}

variable "git_branch" {
  description = "The git branch name for the deployment."
  type        = string
}

variable "git_commit" {
  description = "The git commit hash for the deployment."
  type        = string
}
