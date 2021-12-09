# https://registry.terraform.io/providers/hashicorp/google/latest/docs
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_versions
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference
provider "google" {
  project     = var.project
  region      = var.region
  credentials = file("../../account.json")
}

module "network" {
  source = "../../network"

  name    = var.name
  project = var.project
  region  = var.region
}

module "bastion" {
  source = "../"

  name                 = var.name
  project              = var.project
  region               = var.region
  network              = module.network.network
  public_subnetwork    = module.network.public_subnetwork
  enable_os_login      = false
  enable_ssh_keys      = true
  ssh_path             = var.ssh_path
  ssh_private_key_file = var.ssh_private_key_file
  ssh_public_key_file  = var.ssh_public_key_file
}
