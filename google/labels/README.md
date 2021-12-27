# labels

This module provides a standard and consistent set of labels to be used for resources by other modules.

## Usage

```hcl
module "labels" {
  source = "github.com/gardenbed/terraform-modules/google/labels"

  uuid       = var.uuid
  owner      = var.owner
  git_repo   = var.git_repo
  git_branch = var.git_branch
  git_commit = var.git_commit
}

resource "google_compute_instance" "vm" {
  ...

  labels = merge(module.labels.common, {
    name = "VM"
  })
}
```
