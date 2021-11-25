# https://www.terraform.io/docs/language/expressions/version-constraints.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
terraform {
  # Reusable modules should constrain only their minimum allowed versions of Terraform and providers.
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.66"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
data "aws_caller_identity" "current" {}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones
data "aws_availability_zones" "available" {}
