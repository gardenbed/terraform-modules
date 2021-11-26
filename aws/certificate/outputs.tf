# https://www.terraform.io/docs/language/values/outputs.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

output "certificate_arn" {
  description = "The certificate ARN (Amazon Resource Name)."
  value       = aws_acm_certificate.main.arn
}
