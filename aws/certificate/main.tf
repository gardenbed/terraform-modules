# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#create_before_destroy

# ====================================================================================================
#  CERTIFICATE
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate
# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html
resource "aws_acm_certificate" "main" {
  validation_method         = "DNS"
  domain_name               = var.cert_domain
  subject_alternative_names = var.cert_alt_domains
  tags                      = var.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation
resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = aws_route53_record.validation.*.fqdn
}

# ====================================================================================================
#  ROUTE 53
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "validation" {
  for_each = {
    for v in aws_acm_certificate.main.domain_validation_options : v.domain_name => {
      name   = v.resource_record_name
      record = v.resource_record_value
      type   = v.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [ each.value.record ]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone
data "aws_route53_zone" "main" {
  name = "${var.domain}."
}
