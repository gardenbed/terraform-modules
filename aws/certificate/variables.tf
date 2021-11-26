# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "domain" {
  description = "Your domain name."
  type        = string
}

variable "cert_domain" {
  description = "Main domain or subdomain for the certificate."
  type        = string
}

variable "cert_alt_domains" {
  description = "Alternative domains or subdomains for the certificate."
  type        = set(string)
}

variable "common_tags" {
  description = "A map of common tags for the certificate."
  type        = map(string)
  default     = {}
}
