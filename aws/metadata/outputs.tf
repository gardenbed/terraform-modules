# https://www.terraform.io/docs/language/values/outputs.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

output "common_tags" {
  description = "A map of common tags for resources."
  value = {
    UUID = var.uuid
    Owner = var.owner
    GitRepo = var.git_repo
    GitBranch = var.git_branch
    GitCommit = var.git_commit
  }
}
