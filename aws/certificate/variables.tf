# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "domain" {
  type        = string
  description = "Your domain name."
}

variable "cert_domain" {
  type        = string
  description = "Main domain or subdomain for the certificate."
}

variable "cert_alt_domains" {
  type        = set(string)
  description = "Alternative domains or subdomains for the certificate."
}

variable "metadata" {
  type        = map(string)
  description = "Metadata for the certificate."
}
