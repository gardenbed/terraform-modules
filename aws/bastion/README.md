# network

This module deploys bastion hosts for accessing to private instances indirectly via ssh.
You can ssh to a bastion host and then access instances in private subnets through the bastion host.

## Usage

```hcl
module "network" {
  source = "github.com/gardenbed/terraform-modules/aws/network"

  name     = "example"
  region   = "us-east-1"
  az_count = 3
}

module "bastion" {
  source = "github.com/gardenbed/terraform-modules/aws/bastion"

  name                = "example"
  region              = "us-east-1"
  vpc                 = module.network.vpc
  public_subnets      = slice(module.network.public_subnets, 0, 2)
  ssh_public_key_file = "bastion.pub"
  ssh_config_file     = {
    private_key_file = "bastion.pem"
  }
}
```

## Documentation

Bastion [EC2 Instances](https://docs.aws.amazon.com/ec2/index.html)
are managed by an [Autoscaling Group](https://docs.aws.amazon.com/autoscaling/index.html).
Bastion instances use a Debian [AMI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)
and are deployed to the public subnetworks, so they can be accessed from the outside world.
The instances are accessbile from the Internet by default, but the trusted incoming addresses can be configured.

There is an external [Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html)
in front of the Bastion hosts with an [Elastic IP](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html)
per availability zone (public subnet).

**You can determine the number of availability zones and Bastion hosts using the public subnets.**

## Accessing Bastion Hosts

Bastion hosts can be accessed through SSH with user-provided SSH keys.

An SSH config file can be generated for easily accessing the Bastion hosts through the load balancer.

    $ ssh -F config-<name> bastion
