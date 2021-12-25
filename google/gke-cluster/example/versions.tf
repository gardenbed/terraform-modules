# https://www.terraform.io/docs/language/settings/index.html
# https://www.terraform.io/docs/language/expressions/version-constraints.html

terraform {
  # Root modules should constraint both a lower and upper bound on versions of Terraform and providers.
  required_version = "~> 1.1"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.5"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}
