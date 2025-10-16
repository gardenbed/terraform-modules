# https://www.terraform.io/docs/language/settings/index.html
# https://www.terraform.io/docs/language/expressions/version-constraints.html

terraform {
  # Root modules should constraint both a lower and upper bound on versions of Terraform and providers.
  required_version = "~> 1.12"

  required_providers {
    # https://registry.terraform.io/providers/hashicorp/google/latest
    google = {
      source  = "hashicorp/google"
      version = "~> 6.41"
    }
    # https://registry.terraform.io/providers/hashicorp/google-beta/latest
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 7.0"
    }
    # https://registry.terraform.io/providers/hashicorp/local/latest
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    # https://registry.terraform.io/providers/hashicorp/template/latest
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}
