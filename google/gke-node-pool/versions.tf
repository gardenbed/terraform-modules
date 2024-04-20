# https://www.terraform.io/docs/language/settings/index.html
# https://www.terraform.io/docs/language/expressions/version-constraints.html

terraform {
  # Reusable modules should constrain only their minimum allowed versions of Terraform and providers.
  required_version = ">= 1.8.1"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.25.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.25.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.1"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
  }
}
