# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "certificate" {
  source = "../"

  domain           = var.domain
  cert_domain      = var.domain
  cert_alt_domains = [ "api.${var.domain}", "app.${var.domain}" ]
}
