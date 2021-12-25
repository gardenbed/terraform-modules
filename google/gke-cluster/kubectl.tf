# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "kubeconfig" {
  count = var.public_cluster ? 1 : 0

  filename             = "${abspath(var.kubeconfig_path)}/kubeconfig-${var.name}"
  content              = data.template_file.kubeconfig.0.rendered
  file_permission      = "0600"
  directory_permission = "0755"
}

# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
data "template_file" "kubeconfig" {
  count = var.public_cluster ? 1 : 0

  template = file("${path.module}/kubeconfig.tpl")
  vars = {
    access_token                  = data.google_client_config.provider.access_token
    cluster_name                  = google_container_cluster.cluster.name
    cluster_endpoint              = google_container_cluster.cluster.endpoint
    cluster_certificate_authority = google_container_cluster.cluster.master_auth.0.cluster_ca_certificate
  }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
data "google_client_config" "provider" {}
