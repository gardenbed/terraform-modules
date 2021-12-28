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

module "cluster" {
  source = "../"

  name                   = var.name
  project                = var.project
  region                 = var.region
  public_cluster         = true
  network                = module.network.network.id
  private_subnetwork     = module.network.private_subnetwork.id
  public_subnetwork_cidr = module.network.public_subnetwork.primary_cidr
  kubeconfig_path        = var.kubeconfig_path
}
