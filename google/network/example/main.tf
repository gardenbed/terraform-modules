# https://registry.terraform.io/providers/hashicorp/google/latest/docs
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_versions
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference
provider "google" {
  project     = var.project
  region      = var.region
  credentials = file("../../account.json")
}

module "network" {
  source = "../"

  name    = var.name
  project = var.project
  region  = var.region
}
