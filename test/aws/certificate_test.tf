variable "domain" {
  type = string
}

module "certificate" {
  source = "../../aws/certificate"

  domain      = var.domain
  cert_domain = var.domain

  cert_alt_domains = [
    "api.${var.domain}",
    "app.${var.domain}",
  ]

  metadata = merge(module.metadata.common, {
    "Name" = var.name
  })
}
