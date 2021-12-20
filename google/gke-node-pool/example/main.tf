# https://registry.terraform.io/providers/hashicorp/google/latest/docs
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_versions
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
}

provider "google-beta" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
}

module "network" {
  source = "../../network"

  name    = var.name
  project = var.project
  region  = var.region
}

module "bastion" {
  source = "../../bastion"

  name                = var.name
  project             = var.project
  region              = var.region
  network             = module.network.network
  public_subnetwork   = module.network.public_subnetwork
  enable_os_login     = false
  enable_ssh_keys     = true
  ssh_public_key_file = var.bastion_public_key_file
}

module "cluster" {
  source = "../../gke-cluster"

  name               = var.name
  project            = var.project
  region             = var.region
  network            = module.network.network
  public_subnetwork  = module.network.public_subnetwork
  private_subnetwork = module.network.private_subnetwork
  public_cluster     = true
}

module "node_pool" {
  source = "../"

  name                  = var.name
  project               = var.project
  region                = var.region
  cluster_id            = module.cluster.id
  service_account_email = module.cluster.service_account_email
  network_tag           = module.network.private_subnetwork.network_tag

  ssh = {
    node_pool_public_key_file = var.node_pool_public_key_file
  }

  ssh_config_file = {
    bastion_address            = module.bastion.address
    bastion_private_key_file   = var.bastion_private_key_file
    node_pool_cidr             = module.network.private_subnetwork.primary_cidr
    node_pool_private_key_file = var.node_pool_private_key_file
  }
}
