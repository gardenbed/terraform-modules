# network

This module deploys the networking infrastructure for a highly available cluster and/or a distributed system.
This module creates `public` and `private` subnets per availability zone.

## Usage

```hcl
module "network" {
  source = "github.com/gardenbed/terraform-modules/aws/network"

  name     = "example"
  region   = "us-east-1"
  az_count = 3
}
```

## Documentation

A new [VPC](https://docs.aws.amazon.com/vpc/index.html) will be created for each network.
There are two sets of [Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html) are deployed into the VPC.
The **public** and **private** subnets.

The public subnets are assoicated with a single [Internet Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html).
Each private subnet is associated with a [NAT Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
and an [Elastic IP](https://aws.amazon.com/premiumsupport/knowledge-center/elastic-ip-charges/).
**Consider your Elastic IP quotas when deciding on the number of availability zones required.**

The public subnets are associated with a single [Route Table](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html).
The public route table has an **IPv4** route to the Internet (`0.0.0.0/0`) as well as **IPv6** route to the Internete (`::/0`).
Each private subnet is associated with a [Route Table](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html).
Each private route table has an **IPv4** route to the Internet (`0.0.0.0/0`) as well as **IPv6** route to the Internete (`::/0`).

All traffic inside the VPC is allowed. All outgoing traffic from the VPC to the Internet is also allowed by default.
The trusted outgoing addresses can be configured.
