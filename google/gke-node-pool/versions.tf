# https://www.terraform.io/docs/language/settings/index.html
# https://www.terraform.io/docs/language/expressions/version-constraints.html

terraform {
  # Reusable modules should constrain only their minimum allowed versions of Terraform and providers.
  required_version = ">= 1.12.2"

  required_providers {
    # https://registry.terraform.io/providers/hashicorp/google/latest
    google = {
      source  = "hashicorp/google"
      version = ">= 6.41.0"
    }
    # https://registry.terraform.io/providers/hashicorp/google-beta/latest
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.41.0"
    }
    # https://registry.terraform.io/providers/hashicorp/local/latest
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.3"
    }
    # https://registry.terraform.io/providers/hashicorp/template/latest
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
  }
}
