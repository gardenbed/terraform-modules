# https://www.terraform.io/docs/language/values/outputs.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

output "name" {
  description = "The cluster name."
  value       = aws_eks_node_group.node_group.id
}

output "arn" {
  description = "The cluster ARN (Amazon Resource Name)."
  value       = aws_eks_node_group.node_group.arn
}

output "status" {
  description = "The cluster status."
  value       = aws_eks_node_group.node_group.status
}
