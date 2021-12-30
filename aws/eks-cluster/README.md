# eks-cluster

This module deploys the control plane for an EKS cluster.
Node groups (managed) and nodes (self-managed) need to be deployed separately.

## Usage

**Private cluster:**

```hcl
module "network" {
  source = "github.com/gardenbed/terraform-modules/aws/network"

  name     = "example"
  region   = "us-east-1"
  az_count = 3
}

module "cluster" {
  source = "github.com/gardenbed/terraform-modules/aws/eks-cluster"

  name               = "example"
  region             = "us-east-1"
  vpc_id             = module.network.vpc.id
  private_subnet_ids = module.network.private_subnets.*.id
}
```

**Public cluster:**

```hcl
module "network" {
  source = "github.com/gardenbed/terraform-modules/aws/network"

  name     = "example"
  region   = "us-east-1"
  az_count = 3
}

module "cluster" {
  source = "github.com/gardenbed/terraform-modules/aws/eks-cluster"

  name               = "example"
  region             = "us-east-1"
  public_cluster     = true
  vpc_id             = module.network.vpc.id
  private_subnet_ids = module.network.private_subnets.*.id
}
```

## Documentation

The cluster is a *private* cluster by default, but can be deployed as a *public* one too.
**The cluster resources will be always deployed to private subnets.**
A private cluster is only accessible within the same VPC whereas a public cluster can be accessed from the outside world.
If a cluster is public, it is accessible from the Internet by default. The trusted addresses can be configured as needed.

AWS IAM roles can be enabled for using as Kubernetes service accounts (disabled by default).
CloudWatch logs can also be enabled for the cluster. If so, the default retention period is 60 days (can be changed).

A config file is also generated for easily accessing the cluster (if public) using `kubectl` command.

    $ KUBECONFIG=./kubeconfig-<name> kubectl ...
