# https://www.terraform.io/docs/language/settings/index.html
# https://www.terraform.io/docs/language/expressions/version-constraints.html

terraform {
  # Reusable modules should constrain only their minimum allowed versions of Terraform and providers.
  required_version = ">= 1.1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.4.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.1.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
  }
}
