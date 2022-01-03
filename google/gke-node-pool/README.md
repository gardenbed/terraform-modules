# gke-node-pool

This module deploys a node pool for a GKE cluster.

## Usage

**Private cluster with OS login:**

```hcl
module "network" {
  source = "github.com/gardenbed/terraform-modules/google/network"

  name    = "example"
  project = "my-project"
  region  = "us-east1"
}

module "cluster" {
  source = "github.com/gardenbed/terraform-modules/google/gke-cluster"

  name               = "example"
  project            = "my-project"
  region             = "us-east1"
  network            = module.network.network
  private_subnetwork = module.network.private_subnetwork
}

module "node_pool" {
  source = "github.com/gardenbed/terraform-modules/google/gke-node-pool"

  name                  = "example"
  project               = "my-project"
  region                = "us-east1"
  cluster_id            = module.cluster.id
  service_account_email = module.cluster.service_account_email
  network_tag           = module.network.private_subnetwork.network_tag

  ssh = {
    node_pool_public_key_file = "node-pool.pub"
  }
}
```

**Public cluster with SSH keys:**

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
}

module "cluster" {
  source = "github.com/gardenbed/terraform-modules/google/gke-cluster"

  name              = "example"
  project           = "my-project"
  region            = "us-east1"
  public_cluster    = true
  network           = module.network.network
  public_subnetwork = module.network.public_subnetwork
}

module "node_pool" {
  source = "github.com/gardenbed/terraform-modules/google/gke-node-pool"

  name                  = "example"
  project               = "my-project"
  region                = "us-east1"
  cluster_id            = module.cluster.id
  service_account_email = module.cluster.service_account_email
  network_tag           = module.network.private_subnetwork.network_tag

  ssh = {
    node_pool_public_key_file = "node-pool.pub"
  }

  ssh_config_file = {
    bastion_address            = module.bastion.address
    bastion_private_key_file   = "bastion.pem"
    node_pool_cidr             = module.network.private_subnetwork.primary_cidr
    node_pool_private_key_file = "node-pool.pem"
  }
}
```

## Documentation

A [Node Pool](https://cloud.google.com/kubernetes-engine/docs/concepts/node-pools)
is a managed group of nodes for a GKE cluster that all have the same configuration.

For networking information, please see the cluster documentation [here](../gke-cluster/README.md#networking).

Nodes are distributted in all available zones in the region.
The `initial_node_count`, `min_node_count`, and `max_node_count` denote the initial/minimum/maximum number of nodes in each zone.

The nodes will be automatically repaired (auto repair is always enabled).
The nodes will also be automatically upgraded by default (this can be disabled).

The autoscaling for nodes is enabled by default and the minimum and maximum number of nodes in the node pool can be configured.

Nodes are NOT [Spot VMs](https://cloud.google.com/compute/docs/instances/spot) by default, but they can be configured to be so.
Nodes are NOT [Preemptible VMs](https://cloud.google.com/compute/docs/instances/preemptible) by default, but they can be configured to be so.
The node specifications (image type, machine type, disk type, disk size, etc.) can be configured as needed.

The node instances have [Secure Boot](https://cloud.google.com/compute/shielded-vm/docs/shielded-vm#secure-boot) enabled.
*Secure Boot* helps ensure that the VMs only run authentic software by verifying the digital signature of all boot components.
The [Integrity Monitroing](https://cloud.google.com/compute/shielded-vm/docs/integrity-monitoring) is also enabled for node instances.

[gVisor Sandbox](https://cloud.google.com/kubernetes-engine/docs/concepts/sandbox-pods) can also be enabled if needed.

The nodes can be accessed via SSH indirectly and through the bastion instances.
An SSH config file can be generated for easily accessing the nodes through the Bastion instances.

    $ ssh -F config-<name> <node_private_ip>

## Resources

  - **VPC**
    - [Alias IP ranges overview](https://cloud.google.com/vpc/docs/alias-ip)
  - **GKE**
    - [VPC-native clusters](https://cloud.google.com/kubernetes-engine/docs/concepts/alias-ips)
    - [Autopilot overview](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview)
    - [Standard cluster architecture](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-architecture)
    - [Autopilot cluster architecture](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-architecture)
    - [Types of clusters](https://cloud.google.com/kubernetes-engine/docs/concepts/types-of-clusters)
    - [Private clusters](https://cloud.google.com/kubernetes-engine/docs/concepts/private-cluster-concept)
    - [Cluster autoscaler](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-autoscaler)
    - [Release channels](https://cloud.google.com/kubernetes-engine/docs/concepts/release-channels)
