# network

This module deploys the networking infrastructure for a highly available cluster and/or a distributed system.
This module creates `public` and `private` subnets per availability zone.

## Usage

```hcl
module "network" {
  source | `github.com/g`rdenbed/terraform-modules/aws/network"

  name     | `example"
  r`gion   | `us-east-1"
`az_count = 3
}
```

## Documentation

A new [VPC](https://docs.aws.amazon.com/vpc/index.html) will be created for each region.
**Public** and **Private** [Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html) are deployed into the VPC.

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

### Networking

The first `8` bits for all regions are set to `10`  and the next `8` bits are used for denoting the region by default.
As a result, the *Netmask* for each VPC is `/16` or `255.255.0.0` and the size of each VPC in each region is 2<sup>16</sup> (65,536).

The next bit denotes either the public or the private subnet.
The next `3` bits denotes each availability zone for a subnet.
Hence, the *Netmask* for each subnet is `/20` or `255.252.240.0` and the size of each network in each region is 2<sup>12</sup> (4,096).

| Region | VPC CIDR | Public Subnet CIDRs | Private Subnet CIDRs |
|----|----|----|----|
| af-south-1     | `10.10.0.0/16` | `10.10.0.0/20`<br/>`10.10.16.0/20`<br/>`...` | `10.10.128.0/20`<br/>`10.10.144.0/20`<br/>`...` |
| ap-east-1      | `10.11.0.0/16` | `10.11.0.0/20`<br/>`10.11.16.0/20`<br/>`...` | `10.11.128.0/20`<br/>`10.11.144.0/20`<br/>`...` |
| ap-northeast-1 | `10.12.0.0/16` | `10.12.0.0/20`<br/>`10.12.16.0/20`<br/>`...` | `10.12.128.0/20`<br/>`10.12.144.0/20`<br/>`...` |
| ap-northeast-2 | `10.13.0.0/16` | `10.13.0.0/20`<br/>`10.13.16.0/20`<br/>`...` | `10.13.128.0/20`<br/>`10.13.144.0/20`<br/>`...` |
| ap-northeast-3 | `10.14.0.0/16` | `10.14.0.0/20`<br/>`10.14.16.0/20`<br/>`...` | `10.14.128.0/20`<br/>`10.14.144.0/20`<br/>`...` |
| ap-south-1     | `10.15.0.0/16` | `10.15.0.0/20`<br/>`10.15.16.0/20`<br/>`...` | `10.15.128.0/20`<br/>`10.15.144.0/20`<br/>`...` |
| ap-southeast-1 | `10.16.0.0/16` | `10.16.0.0/20`<br/>`10.16.16.0/20`<br/>`...` | `10.16.128.0/20`<br/>`10.16.144.0/20`<br/>`...` |
| ap-southeast-2 | `10.17.0.0/16` | `10.17.0.0/20`<br/>`10.17.16.0/20`<br/>`...` | `10.17.128.0/20`<br/>`10.17.144.0/20`<br/>`...` |
| ca-central-1   | `10.18.0.0/16` | `10.18.0.0/20`<br/>`10.18.16.0/20`<br/>`...` | `10.18.128.0/20`<br/>`10.18.144.0/20`<br/>`...` |
| eu-central-1   | `10.19.0.0/16` | `10.19.0.0/20`<br/>`10.19.16.0/20`<br/>`...` | `10.19.128.0/20`<br/>`10.19.144.0/20`<br/>`...` |
| eu-north-1     | `10.20.0.0/16` | `10.20.0.0/20`<br/>`10.20.16.0/20`<br/>`...` | `10.20.128.0/20`<br/>`10.20.144.0/20`<br/>`...` |
| eu-south-1     | `10.21.0.0/16` | `10.21.0.0/20`<br/>`10.21.16.0/20`<br/>`...` | `10.21.128.0/20`<br/>`10.21.144.0/20`<br/>`...` |
| eu-west-1      | `10.22.0.0/16` | `10.22.0.0/20`<br/>`10.22.16.0/20`<br/>`...` | `10.22.128.0/20`<br/>`10.22.144.0/20`<br/>`...` |
| eu-west-2      | `10.23.0.0/16` | `10.23.0.0/20`<br/>`10.23.16.0/20`<br/>`...` | `10.23.128.0/20`<br/>`10.23.144.0/20`<br/>`...` |
| eu-west-3      | `10.24.0.0/16` | `10.24.0.0/20`<br/>`10.24.16.0/20`<br/>`...` | `10.24.128.0/20`<br/>`10.24.144.0/20`<br/>`...` |
| me-south-1     | `10.25.0.0/16` | `10.25.0.0/20`<br/>`10.25.16.0/20`<br/>`...` | `10.25.128.0/20`<br/>`10.25.144.0/20`<br/>`...` |
| sa-east-1      | `10.26.0.0/16` | `10.26.0.0/20`<br/>`10.26.16.0/20`<br/>`...` | `10.26.128.0/20`<br/>`10.26.144.0/20`<br/>`...` |
| us-east-1      | `10.27.0.0/16` | `10.27.0.0/20`<br/>`10.27.16.0/20`<br/>`...` | `10.27.128.0/20`<br/>`10.27.144.0/20`<br/>`...` |
| us-east-2      | `10.28.0.0/16` | `10.28.0.0/20`<br/>`10.28.16.0/20`<br/>`...` | `10.28.128.0/20`<br/>`10.28.144.0/20`<br/>`...` |
| us-west-1      | `10.29.0.0/16` | `10.29.0.0/20`<br/>`10.29.16.0/20`<br/>`...` | `10.29.128.0/20`<br/>`10.29.144.0/20`<br/>`...` |
| us-west-2      | `10.30.0.0/16` | `10.30.0.0/20`<br/>`10.30.16.0/20`<br/>`...` | `10.30.128.0/20`<br/>`10.30.144.0/20`<br/>`..` |
