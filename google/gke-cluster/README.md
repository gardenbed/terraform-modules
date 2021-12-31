# gke-cluster

This module deploys the control plane for a GKE cluster.
Node pools need to be deployed separately.

## Usage

**Private cluster:**

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
  network            = module.network.network.id
  private_subnetwork = module.network.private_subnetwork.id
}
```

**Public cluster:**

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
  public_cluster     = true
  network            = module.network.network.id
  private_subnetwork = module.network.private_subnetwork.id
}
```

## Documentation

The cluster is a **Regional** and **VPC-native** cluster. The cluster is *private* by default, but can be deployed as *public* too.
**The cluster resources will be always deployed to private subnets. The cluster is always a private cluster**.
If `public_cluster` is `false` (default), the cluster endpoint is private and only the public subnetwork (`public_subnetwork_cidr`) is allowed to access the cluster through HTTPS.
If `public_cluster` is `true`, the cluster endpoint is public and can be accessed from the Internet.

You can specify a secondary range name in the cluster's subnetwork (public or private) for the pod IP addresses (`pods_secondary_range_name`).
You can also specify a secondary range name in the cluster's subnetwork (public or private) for the service IP addresses (`services_secondary_range_name`).
If `pods_secondary_range_name` is not set (the default behavior), a `/16` netmask will be used for the pod IP addresses.
If `services_secondary_range_name` is not set (the default behavior), a `/16` netmask will be used for the service IP addresses.

[Shielded Nodes](https://cloud.google.com/kubernetes-engine/docs/how-to/shielded-gke-nodes) and
[Binary Authorization](https://cloud.google.com/binary-authorization/docs/overview) are enabled for the cluster.
The default [Release Channel](https://cloud.google.com/kubernetes-engine/docs/concepts/release-channels) is `STABLE` and it can be modified.

[Cluster autoscaling](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-autoscaler),
[Vertical Pod autoscaling](https://cloud.google.com/kubernetes-engine/docs/concepts/verticalpodautoscaler), and
[Horizontal Pod autoscaling](https://cloud.google.com/kubernetes-engine/docs/concepts/horizontalpodautoscaler) are enabled by default.
They can be separately configured or disabled as needed.

Stackdriver logging and monitoring are enabled by default for the cluster, but they can be disabled if needed.
You can enable the cluster *notifications* by setting the `notification_topic_id` variable.

A new [service account](https://cloud.google.com/iam/docs/service-accounts) is created for the cluster.
**This service account should be used for creating node pools for the cluster.**

A config file is also generated for easily accessing the cluster (if public) using `kubectl` command.

    $ KUBECONFIG=./kubeconfig-<name> kubectl ...

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
