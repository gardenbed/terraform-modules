module "metadata" {
  source = "../"

  uuid       = var.uuid
  owner      = var.owner
  git_repo   = var.git_repo
  git_branch = var.git_branch
  git_commit = var.git_commit
}
