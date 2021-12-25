# https://www.terraform.io/docs/language/values/outputs.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

output "id" {
  description = "The cluster ID."
  value       = google_container_cluster.cluster.id
}

output "name" {
  description = "The cluster name."
  value       = google_container_cluster.cluster.name
}

output "version" {
  description = "The current version of the cluster control plane."
  value       = google_container_cluster.cluster.master_version
}

output "services_cidr" {
  description = "The CIDR block for the Kubernetes services in the cluster."
  value       = google_container_cluster.cluster.services_ipv4_cidr
}

output "endpoint" {
  description = "The IP address of the Kubernetes cluster control plane."
  value       = google_container_cluster.cluster.endpoint
}

output "cluster_ca_cert" {
  description = "Public certificate authority that is the root of trust for the cluster (base64-encoded)."
  value       = google_container_cluster.cluster.master_auth.0.cluster_ca_certificate
}

output "client_cert" {
  description = "Public certificate for clients to authenticate to the cluster endpoint (base64-encoded)."
  value       = google_container_cluster.cluster.master_auth.0.client_certificate
}

output "client_key" {
  description = "Private key for clients to authenticate to the cluster endpoint (base64-encoded)."
  value       = google_container_cluster.cluster.master_auth.0.client_key
}

output "service_account_email" {
  description = "The service account email for the cluster."
  value       = google_service_account.cluster.email
}

output "kubeconfig_file" {
  description = "The path to kubectl config file for the cluster."
  value       = var.public_cluster ? local_file.kubeconfig.0.filename : null
}
