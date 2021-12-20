# https://registry.terraform.io/providers/hashicorp/google/latest/docs
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_versions
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference
provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
}

module "network" {
  source = "../"

  name                     = var.name
  project                  = var.project
  region                   = var.region
  public_secondary_ranges  = ["foo"]
  private_secondary_ranges = ["bar"]
}
