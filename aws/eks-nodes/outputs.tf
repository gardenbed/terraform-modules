# https://www.terraform.io/docs/language/values/outputs.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

output "iam_role_arn" {
  description = "The IAM Role ARN (Amazon Resource Name) for the nodes."
  value       = aws_iam_role.nodes.arn
}

output "security_group_id" {
  description = "The security group id for the nodes."
  value       = aws_security_group.nodes.id
}

output "instances" {
  description = "The list of instances (nodes)."
  value = [for i, v in data.aws_instances.instances.ids: {
    id         = data.aws_instances.instances.ids[i]
    private_ip = data.aws_instances.instances.private_ips[i]
  }]
}

output "ssh_config_file" {
  description = "The path to SSH config file for the bastion hosts and nodes."
  value       = local_file.ssh_config.filename
}
