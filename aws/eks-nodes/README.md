# eks-nodes

This module deploys self-managed nodes for an EKS cluster.

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

module "nodes" {
  source = "github.com/gardenbed/terraform-modules/aws/eks-nodes"

  name                                 = "example"
  cluster_name                         = module.cluster.name
  cluster_additional_security_group_id = module.cluster.additional_security_group_ids[0]
  subnet_cidrs                         = module.network.private_subnets.*.cidr

  ssh = {
    bastion_security_group_id = module.bastion.security_group_id
    nodes_public_key_file     = "nodes.pub"
  }

  ssh_config_file = {
    bastion_address          = module.bastion.load_balancer_dns_name
    bastion_private_key_file = "bastion.pem"
    nodes_private_key_file   = "nodes.pem"
  }
}

module "nodes_auth" {
  source = "github.com/gardenbed/terraform-modules/aws/eks-nodes-auth"

  iam_role_arns = [ module.nodes.iam_role_arn ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.cluster.name
}
```

## Documentation

This module deploys a set of self-managed nodes for an EKS cluster
(it is recommended to use the `eks-node-group` module).

The nodes are managed by an [Autoscaling Group](https://docs.aws.amazon.com/autoscaling/index.html) and
node instances are provisioned by a [Launch Template](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html).
The instance specifications (instance type, disk size, number of nodes, etc.) can be configured.

**The `subnet_cidrs` netmask is assumed to be `/24` (see [here](./ssh.tf#25)).**
The nodes can access the Internet by default, but the trusted outgoing addresses can be configured if needed.

The nodes can be accessed via SSH indirectly and through the bastion hosts.
An SSH config file can be generated for easily accessing the nodes through the Bastion hosts.

    $ ssh -F config-<name> <node_private_ip>

### Networking

Nodes are assigned IP addresses from the subnet (private) CIDRs.
