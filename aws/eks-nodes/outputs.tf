# https://www.terraform.io/docs/language/values/outputs.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

output "iam_role_arn" {
  description = "The IAM Role ARN (Amazon Resource Name) for the nodes."
  value       = aws_iam_role.nodes.arn
}

output "min_size" {
  description = "The minimum number of nodes in the auto scaling group."
  value       = aws_autoscaling_group.nodes.min_size
}

output "desired_capacity" {
  description = "The desired number of nodes in the auto scaling group."
  value       = aws_autoscaling_group.nodes.desired_capacity
}

output "max_size" {
  description = "The maximum number of nodes in the auto scaling group."
  value       = aws_autoscaling_group.nodes.max_size
}
