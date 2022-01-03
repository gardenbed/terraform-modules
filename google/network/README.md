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

A new `Regional` [Network](https://cloud.google.com/vpc/docs/vpc) will be created for a **region**.
**Public** and **Private** subnetworks are deployed for each network in a region.

The public subnetwork have [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access) disabled
while the the private subnetwork have the [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access) enabled.

A [Cloud Router](https://cloud.google.com/network-connectivity/docs/router/concepts/overview) is created
and a [Cloud NAT](https://cloud.google.com/nat/docs/overview) allows outbound access to the Internet
for all *primary* and *secondary* address ranges in the *public* and *private* subnetworks.

The default [Firewall](https://cloud.google.com/vpc/docs/firewalls) rules for public subnetwork
allow internral communication within the public subnetwork and outgoing access to the trusted addresses (default is the Internet).
The default [Firewall](https://cloud.google.com/vpc/docs/firewalls) rules for private subnetwork
allow internral communication within the private subnetwork and outgoing access to the trusted addresses (default is the Internet).

By default, **ICMP** and **SSH** incoming traffic from the Internet to the instances in the public subnetwork are enabled.
SSH traffic from the instances in the public subnetwork to the instances in the private subnetwork are also enabled by default.
You can restrict the trusted incoming addressed or completely disable these rules.

The instances in the public subnetwork should have the `public_subnetwork.network_tag` set
and the instances in the private subnetwork should have the `private_subnetwork.network_tag` set.

**You can define up to three secondary ranges for each of subnetworks (public and private).**

### Addressing

The first `8` bits for all regions are set to `10`  and the next `5` bits are used for denoting the region by default.
As a result, the *Netmask* for each network is `/13` or `255.248.0.0` and the size of each network in each region is 2<sup>19</sup> (524,288).

The next bit denotes either the public or the private subnetwork.
Hence, the *Netmask* for each subnetwork is `/14` or `255.252.0.0` and the size of each network in each region is 2<sup>18</sup> (262,144).

Each subnetwork has a primary address range and can have multiple secondary address ranges as well.
The next `2` bits are reserved for primary and secondary address ranges for each subnetwork.
Therefore, the *Netmask* for each address range is `/16` or `255.255.0.0` and the size of each address range is 2<sup>16</sup> (65,536).
**Each subnetwork can have up to `three` secondary address ranges.**

| Region | Network CIDR | Public Subnetwork<br/>Primary CIDR | Public Subnetwork<br/>Secondary CIDRs | Private Subnetwork<br/>Primary CIDR | Private Subnetwork<br/>Secondary CIDRs |
|----|----|----|----|----|----|
| asia-east1              | `10.8.0.0/13`   | `10.8.0.0/16`   | `10.9.0.0/16`<br/>`10.10.0.0/16`<br/>`10.11.0.0/16`     | `10.12.0.0/16`  | `10.13.0.0/16`<br/>`10.14.0.0/16`<br/>`10.15.0.0/16`    |
| asia-east2              | `10.16.0.0/13`  | `10.16.0.0/16`  | `10.17.0.0/16`<br/>`10.18.0.0/16`<br/>`10.19.0.0/16`    | `10.20.0.0/16`  | `10.21.0.0/16`<br/>`10.22.0.0/16`<br/>`10.23.0.0/16`    |
| asia-northeast1         | `10.24.0.0/13`  | `10.24.0.0/16`  | `10.25.0.0/16`<br/>`10.26.0.0/16`<br/>`10.27.0.0/16`    | `10.28.0.0/16`  | `10.29.0.0/16`<br/>`10.30.0.0/16`<br/>`10.31.0.0/16`    |
| asia-northeast2         | `10.32.0.0/13`  | `10.32.0.0/16`  | `10.33.0.0/16`<br/>`10.34.0.0/16`<br/>`10.35.0.0/16`    | `10.36.0.0/16`  | `10.37.0.0/16`<br/>`10.38.0.0/16`<br/>`10.39.0.0/16`    |
| asia-northeast3         | `10.40.0.0/13`  | `10.40.0.0/16`  | `10.41.0.0/16`<br/>`10.42.0.0/16`<br/>`10.43.0.0/16`    | `10.44.0.0/16`  | `10.45.0.0/16`<br/>`10.46.0.0/16`<br/>`10.47.0.0/16`    |
| asia-south1             | `10.48.0.0/13`  | `10.48.0.0/16`  | `10.49.0.0/16`<br/>`10.50.0.0/16`<br/>`10.51.0.0/16`    | `10.52.0.0/16`  | `10.53.0.0/16`<br/>`10.54.0.0/16`<br/>`10.55.0.0/16`    |
| asia-south2             | `10.56.0.0/13`  | `10.56.0.0/16`  | `10.57.0.0/16`<br/>`10.58.0.0/16`<br/>`10.59.0.0/16`    | `10.60.0.0/16`  | `10.61.0.0/16`<br/>`10.62.0.0/16`<br/>`10.63.0.0/16`    |
| asia-southeast1         | `10.64.0.0/13`  | `10.64.0.0/16`  | `10.65.0.0/16`<br/>`10.66.0.0/16`<br/>`10.67.0.0/16`    | `10.68.0.0/16`  | `10.69.0.0/16`<br/>`10.70.0.0/16`<br/>`10.71.0.0/16`    |
| asia-southeast2         | `10.72.0.0/13`  | `10.72.0.0/16`  | `10.73.0.0/16`<br/>`10.74.0.0/16`<br/>`10.75.0.0/16`    | `10.76.0.0/16`  | `10.77.0.0/16`<br/>`10.78.0.0/16`<br/>`10.79.0.0/16`    |
| australia-southeast1    | `10.80.0.0/13`  | `10.80.0.0/16`  | `10.81.0.0/16`<br/>`10.82.0.0/16`<br/>`10.83.0.0/16`    | `10.84.0.0/16`  | `10.85.0.0/16`<br/>`10.86.0.0/16`<br/>`10.87.0.0/16`    |
| australia-southeast2    | `10.88.0.0/13`  | `10.88.0.0/16`  | `10.89.0.0/16`<br/>`10.90.0.0/16`<br/>`10.91.0.0/16`    | `10.92.0.0/16`  | `10.93.0.0/16`<br/>`10.94.0.0/16`<br/>`10.95.0.0/16`    |
| europe-central2         | `10.96.0.0/13`  | `10.96.0.0/16`  | `10.97.0.0/16`<br/>`10.98.0.0/16`<br/>`10.99.0.0/16`    | `10.100.0.0/16` | `10.101.0.0/16`<br/>`10.102.0.0/16`<br/>`10.103.0.0/16` |
| europe-north1           | `10.104.0.0/13` | `10.104.0.0/16` | `10.105.0.0/16`<br/>`10.106.0.0/16`<br/>`10.107.0.0/16` | `10.108.0.0/16` | `10.109.0.0/16`<br/>`10.110.0.0/16`<br/>`10.111.0.0/16` |
| europe-west1            | `10.112.0.0/13` | `10.112.0.0/16` | `10.113.0.0/16`<br/>`10.114.0.0/16`<br/>`10.115.0.0/16` | `10.116.0.0/16` | `10.117.0.0/16`<br/>`10.118.0.0/16`<br/>`10.119.0.0/16` |
| europe-west2            | `10.120.0.0/13` | `10.120.0.0/16` | `10.121.0.0/16`<br/>`10.122.0.0/16`<br/>`10.123.0.0/16` | `10.124.0.0/16` | `10.125.0.0/16`<br/>`10.126.0.0/16`<br/>`10.127.0.0/16` |
| europe-west3            | `10.128.0.0/13` | `10.128.0.0/16` | `10.129.0.0/16`<br/>`10.130.0.0/16`<br/>`10.131.0.0/16` | `10.132.0.0/16` | `10.133.0.0/16`<br/>`10.134.0.0/16`<br/>`10.135.0.0/16` |
| europe-west4            | `10.136.0.0/13` | `10.136.0.0/16` | `10.137.0.0/16`<br/>`10.138.0.0/16`<br/>`10.139.0.0/16` | `10.140.0.0/16` | `10.141.0.0/16`<br/>`10.142.0.0/16`<br/>`10.143.0.0/16` |
| europe-west6            | `10.144.0.0/13` | `10.144.0.0/16` | `10.145.0.0/16`<br/>`10.146.0.0/16`<br/>`10.147.0.0/16` | `10.148.0.0/16` | `10.149.0.0/16`<br/>`10.146.0.0/16`<br/>`10.151.0.0/16` |
| northamerica-northeast1 | `10.152.0.0/13` | `10.152.0.0/16` | `10.153.0.0/16`<br/>`10.154.0.0/16`<br/>`10.155.0.0/16` | `10.156.0.0/16` | `10.157.0.0/16`<br/>`10.158.0.0/16`<br/>`10.159.0.0/16` |
| northamerica-northeast2 | `10.160.0.0/13` | `10.160.0.0/16` | `10.161.0.0/16`<br/>`10.162.0.0/16`<br/>`10.163.0.0/16` | `10.164.0.0/16` | `10.165.0.0/16`<br/>`10.166.0.0/16`<br/>`10.167.0.0/16` |
| southamerica-east1      | `10.168.0.0/13` | `10.168.0.0/16` | `10.169.0.0/16`<br/>`10.170.0.0/16`<br/>`10.171.0.0/16` | `10.172.0.0/16` | `10.173.0.0/16`<br/>`10.174.0.0/16`<br/>`10.175.0.0/16` |
| southamerica-west1      | `10.176.0.0/13` | `10.176.0.0/16` | `10.177.0.0/16`<br/>`10.178.0.0/16`<br/>`10.179.0.0/16` | `10.180.0.0/16` | `10.181.0.0/16`<br/>`10.182.0.0/16`<br/>`10.183.0.0/16` |
| us-central1             | `10.184.0.0/13` | `10.184.0.0/16` | `10.185.0.0/16`<br/>`10.186.0.0/16`<br/>`10.187.0.0/16` | `10.188.0.0/16` | `10.189.0.0/16`<br/>`10.190.0.0/16`<br/>`10.191.0.0/16` |
| us-east1                | `10.192.0.0/13` | `10.192.0.0/16` | `10.193.0.0/16`<br/>`10.194.0.0/16`<br/>`10.195.0.0/16` | `10.196.0.0/16` | `10.197.0.0/16`<br/>`10.198.0.0/16`<br/>`10.199.0.0/16` |
| us-east4                | `10.200.0.0/13` | `10.200.0.0/16` | `10.201.0.0/16`<br/>`10.202.0.0/16`<br/>`10.203.0.0/16` | `10.204.0.0/16` | `10.205.0.0/16`<br/>`10.206.0.0/16`<br/>`10.207.0.0/16` |
| us-west1                | `10.208.0.0/13` | `10.208.0.0/16` | `10.209.0.0/16`<br/>`10.210.0.0/16`<br/>`10.211.0.0/16` | `10.212.0.0/16` | `10.213.0.0/16`<br/>`10.214.0.0/16`<br/>`10.215.0.0/16` |
| us-west2                | `10.216.0.0/13` | `10.216.0.0/16` | `10.217.0.0/16`<br/>`10.218.0.0/16`<br/>`10.219.0.0/16` | `10.220.0.0/16` | `10.221.0.0/16`<br/>`10.222.0.0/16`<br/>`10.223.0.0/16` |
| us-west3                | `10.224.0.0/13` | `10.224.0.0/16` | `10.225.0.0/16`<br/>`10.226.0.0/16`<br/>`10.227.0.0/16` | `10.228.0.0/16` | `10.229.0.0/16`<br/>`10.230.0.0/16`<br/>`10.231.0.0/16` |
| us-west4                | `10.232.0.0/13` | `10.232.0.0/16` | `10.233.0.0/16`<br/>`10.234.0.0/16`<br/>`10.235.0.0/16` | `10.236.0.0/16` | `10.237.0.0/16`<br/>`10.238.0.0/16`<br/>`10.239.0.0/16` |
