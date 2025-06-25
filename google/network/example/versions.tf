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
  }
}
