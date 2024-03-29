# https://www.terraform.io/docs/language/settings/index.html
# https://www.terraform.io/docs/language/expressions/version-constraints.html

terraform {
  # Reusable modules should constrain only their minimum allowed versions of Terraform and providers.
  required_version = ">= 1.1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.8.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.2"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.2"
    }
  }
}
