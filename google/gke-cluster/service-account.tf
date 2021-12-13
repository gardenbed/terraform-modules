# ====================================================================================================
#  SERVICE ACCOUNT
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "cluster" {
  account_id   = "${var.name}-cluster"
  project      = var.project
  display_name = "GKE Cluster Service Account"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
resource "google_project_iam_member" "cluster" {
  for_each = toset(local.service_account_roles)

  project = var.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.cluster.email}"
}
