# https://www.terraform.io/docs/language/values/outputs.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

output "common" {
  description = "A map of common labels for resources."
  value = {
    UUID      = var.uuid
    Owner     = var.owner
    GitRepo   = var.git_repo
    GitBranch = var.git_branch
    GitCommit = var.git_commit
  }
}
