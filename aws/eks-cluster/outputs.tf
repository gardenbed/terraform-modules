# https://www.terraform.io/docs/language/values/outputs.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

output "name" {
  description = "The cluster name."
  value       = aws_eks_cluster.cluster.id
}

output "arn" {
  description = "The cluster ARN (Amazon Resource Name)."
  value       = aws_eks_cluster.cluster.arn
}

output "version" {
  description = "The cluster Kubernetes version."
  value       = aws_eks_cluster.cluster.version
}

output "status" {
  description = "The cluster status."
  value       = aws_eks_cluster.cluster.status
}

output "certificate_authority" {
  description = "The cluster certificate authority (base64-encoded)."
  value       = aws_eks_cluster.cluster.certificate_authority[0].data
}

output "endpoint" {
  description = "The cluster API server endpoint."
  value       = aws_eks_cluster.cluster.endpoint
}

output "oidc_url" {
  description = "The OpenID Connect provider URL."
  value       = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

output "additional_security_group_ids" {
  description = "Additional security group IDs for the cluster."
  value = [
    aws_security_group.cluster.id
  ]
}

output "kubeconfig_file" {
  description = "The path to kubectl config file for the cluster."
  value       = local_file.kubeconfig.filename
}
