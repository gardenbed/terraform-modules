# https://www.terraform.io/docs/language/values/outputs.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

output "name" {
  description = "The node group name."
  value       = aws_eks_node_group.node_group.id
}

output "arn" {
  description = "The node group ARN (Amazon Resource Name)."
  value       = aws_eks_node_group.node_group.arn
}

output "status" {
  description = "The node group status."
  value       = aws_eks_node_group.node_group.status
}

output "instances" {
  description = "The list of instances in the node group."
  value = [for i, v in data.aws_instances.instances.ids: {
    id         = data.aws_instances.instances.ids[i]
    private_ip = data.aws_instances.instances.private_ips[i]
  }]
}

output "ssh_config_file" {
  description = "The path to SSH config file for the bastion hosts and node group."
  value       = local_file.ssh_config.filename
}
