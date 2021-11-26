# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "iam_role_arns" {
  description = "The list of AWS IAM Roles of the nodes."
  type = list(string)
}
