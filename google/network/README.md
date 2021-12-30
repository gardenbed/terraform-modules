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

## Documentation

A new [Network](https://cloud.google.com/vpc/docs/vpc) with **regional** routing will be created for each network.
There are two sets of **Subnetworks** are deployed into the VPC. The **public** and **private** subnetworks.

The public subnetwork have [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access) disabled
while the the private subnetwork have [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access) enabled.

A [Cloud Router](https://cloud.google.com/network-connectivity/docs/router/concepts/overview) is created
and a [Cloud NAT](https://cloud.google.com/nat/docs/overview) allows outbound access to the Internet
for all *primary* and *secondary* IP ranges in the *public* and *private* subnetworks.

The default [Firewall](https://cloud.google.com/vpc/docs/firewalls) rules for public subnetwork
allows internral communication within the public subnetwork and outgoing access to the trusted addresses (default is the Internet).
The default [Firewall](https://cloud.google.com/vpc/docs/firewalls) rules for private subnetwork
allows internral communication within the private subnetwork and outgoing access to the trusted addresses (default is the Internet).

By default, **ICMP** and **SSH** incoming traffic from the Internet to the instances in the public subnetwork are enabled.
SSH traffic from the instances in the public subnetwork to the instances in the private subnetwork are also enabled by default.
You can restrict the trusted incoming addressed or completely disable these rules.

The instances in the public subnetwork should have the `public_subnetwork.network_tag` set
and the instances in the private subnetwork should have the `private_subnetwork.network_tag` set.

You can define up to three secondary ranges for each of subnetworks (public and private).
