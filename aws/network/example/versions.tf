# https://www.terraform.io/docs/language/settings/index.html
# https://www.terraform.io/docs/language/expressions/version-constraints.html

terraform {
  # Root modules should constraint both a lower and upper bound on versions of Terraform and providers.
  required_version = "~> 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46"
    }
  }
}
