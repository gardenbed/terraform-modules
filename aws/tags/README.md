# tags

This module provides a standard and consistent set of tags to be used for resources by other modules.

## Usage

```hcl
module "tags" {
  source = "github.com/gardenbed/terraform-modules/aws/tags"

  uuid       = "..."
  owner      = "..."
  git_repo   = "..."
  git_branch = "..."
  git_commit = "..."
}

resource "aws_instance" "vm" {
  ...

  tags = merge(module.tags.common, {
    Name = "VM"
  })
}
```
