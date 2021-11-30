# network

This module deploys bastion hosts for accessing to private instances indirectly via ssh.
You can ssh to the bastion host and then access instances in private subnets through the bastion host.

## Examples

```hcl
module "bastion" {
  source = "github.com/gardenbed/terraform-modules/aws/bastion"

  name            = "example"
  region          = "ca-central-1"
  public_key_file = "public_key.pub"
}
```
