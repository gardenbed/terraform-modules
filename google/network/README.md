# network

This module deploys the networking infrastructure for a highly available cluster and/or a distributed system.
This module creates `public` and `private` subnetworks per zone.

## Usage

```hcl
module "network" {
  source = "github.com/gardenbed/terraform-modules/google/network"

  name    = "example"
  project = "my-project"
  region  = "us-east1"
}
```
