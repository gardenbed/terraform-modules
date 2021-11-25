# fabric

This module deploys the required infrastructure for a highly available cluster and/or a distributed system.

This module creates `public` and `private` subnets per availability zone.
Instances launched in `private` subnets cannot be accessed from the Internet.

The `bastion` host can be used for accessing private instances indirectly.
You can ssh to the bastion host and then access instances in private subnets through the bastion host.

## Examples

```hcl
module "infra" {
  source = "github.com/gardenbed/terraform-modules/aws/fabric"

  name               = "test"
  region             = "ca-central-1"
  az_count           = 3
  bastion_public_key = "public_key.pub"
}
```
