# eks-node-group

This module deploys a node group (managed) for an EKS cluster.

## Usage

```hcl
module "network" {
  source = "github.com/gardenbed/terraform-modules/aws/network"

  name     = "example"
  region   = "us-east-1"
  az_count = 3
  private_subnet_tags = {
    "kubernetes.io/cluster/example" = "shared"
  }
}

module "bastion" {
  source = "github.com/gardenbed/terraform-modules/aws/bastion"

  name                = "example"
  region              = "us-east-1"
  vpc                 = module.network.vpc
  public_subnets      = slice(module.network.public_subnets, 0, 1)
  ssh_public_key_file = "bastion.pub"
}

module "cluster" {
  source = "github.com/gardenbed/terraform-modules/aws/eks-cluster"

  name               = "example"
  region             = "us-east-1"
  public_cluster     = true
  vpc_id             = module.network.vpc.id
  private_subnet_ids = module.network.private_subnets.*.id
}

module "node_group" {
  source = "github.com/gardenbed/terraform-modules/aws/eks-node-group"

  name         = "example"
  cluster_name = module.cluster.name
  subnets      = module.network.private_subnets

  ssh = {
    bastion_security_group_id  = module.bastion.security_group_id
    node_group_public_key_file = "node-group.pub"
  }

  ssh_config_file = {
    bastion_address             = module.bastion.load_balancer_dns_name
    bastion_private_key_file    = "bastion.pem"
    node_group_private_key_file = "node-group.pem"
  }
}
```

## Documentation

A [Node Group](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html)
is a managed set of nodes for an EKS cluster. It automates the provisioning and lifecycle management of nodes.
The node group can be deployed to either public or private subnets.
It is recommended to deploy the node group to private subnets, so nodes are not accessible from the outside world.

The instance specifications (instance type, disk size, number of nodes, etc.) can be configured.

The nodes can be accessed via SSH indirectly and through the bastion hosts.
An SSH config file can be generated for easily accessing the nodes through the Bastion hosts.

    $ ssh -F config-<name> <node_private_ip>

### Networking

Nodes are assigned IP addresses from the subnet (private) CIDRs.
