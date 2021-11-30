# network

This module deploys the networking infrastructure for a highly available cluster and/or a distributed system.

This module creates `public` and `private` subnets per availability zone.
Instances launched in `private` subnets cannot be accessed from the Internet.

## Examples

```hcl
module "network" {
  source = "github.com/gardenbed/terraform-modules/aws/network"

  name     = "example"
  region   = "ca-central-1"
  az_count = 3
}
```