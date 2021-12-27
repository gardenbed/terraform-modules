# bastion

This module deploys bastion hosts for accessing to private instances indirectly via ssh.
You can ssh to a bastion host and then access instances in private subnetworks through the bastion host.

## Usage

**With OS login:**

```hcl
module "network" {
  source = "github.com/gardenbed/terraform-modules/google/network"

  name    = "example"
  project = "my-project"
  region  = "us-east1"
}

module "bastion" {
  source = "github.com/gardenbed/terraform-modules/google/bastion"

  name              = "example"
  project           = "my-project"
  region            = "us-east1"
  network           = module.network.network
  public_subnetwork = module.network.public_subnetwork
  enable_os_login   = true
  }
}
```

**With SSH keys:**

```hcl
module "network" {
  source = "github.com/gardenbed/terraform-modules/google/network"

  name    = "example"
  project = "my-project"
  region  = "us-east1"
}

module "bastion" {
  source = "github.com/gardenbed/terraform-modules/google/bastion"

  name                = "example"
  project             = "my-project"
  region              = "us-east1"
  network             = module.network.network
  public_subnetwork   = module.network.public_subnetwork
  enable_os_login     = false
  enable_ssh_keys     = true
  ssh_public_key_file = "bastion.pub"
  ssh_config_file     = {
    private_key_file = "bastion.pem"
  }
}
```

## Documentation

Bastion [Instances](https://cloud.google.com/compute/docs/instances)
are managed by an [Autoscaling Group](https://cloud.google.com/compute/docs/autoscaler)
and a [Regional Managed Instance Group](https://cloud.google.com/compute/docs/instance-groups/distributing-instances-with-regional-instance-groups).
Bastion instances use a Debian [Machine Image](https://cloud.google.com/compute/docs/machine-images)
and are launched into the public subnetworks, so they can be accessed from the outside world.
The instances are accessbile from the Internet by default, but the trusted incoming addresses can be configured.

There is an external [Network Load Balancer](https://cloud.google.com/load-balancing/docs/network)
in front of the Bastion instances with a static [IP Address](https://cloud.google.com/compute/docs/ip-addresses).

## Accessing Bastion Instances

Bastion hosts can be accessed in two ways:

  - OS Login (default)
  - SSH Keys

With [OS Login](https://cloud.google.com/compute/docs/oslogin) and [IAP TCP Forwarding](https://cloud.google.com/iap/docs/using-tcp-forwarding),
you can use your Google Cloud identity to authenticate and access the Bastion instances.
OS Login maintains a consistent Linux user identity across instances and it is the recommended way to manage many users.
IAP TCP forwarding allows establishing an encrypted tunnel over which you can forward SSH, RDP, and other traffic to instances.

    $ gcloud compute instances list --filter="tags:bastion"
    $ gcloud compute ssh <instance-name> --zone=<...>

You can disable the OS login and enable SSH keys for accessing the Bastion instances.

An SSH config file can also be generated for easily accessing the Bastion hosts through the load balancer.

    $ ssh -F config-<name> bastion
