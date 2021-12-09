# ====================================================================================================
#  IAP
# ====================================================================================================

# https://cloud.google.com/iap/docs/enabling-compute-howto
# https://cloud.google.com/iap/docs/using-tcp-forwarding

# https://cloud.google.com/compute/docs/instances/managing-instance-access#grant-iam-roles
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
resource "google_project_iam_member" "bastion" {
  count = var.enable_os_login ? length(local.service_account_roles) : 0

  project = var.project
  role    = local.service_account_roles[count.index]
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

# https://cloud.google.com/compute/docs/instances/managing-instance-access#grant-iam-roles
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam
resource "google_service_account_iam_binding" "bastion" {
  count = var.enable_os_login ? 1 : 0

  service_account_id = google_service_account.bastion.id
  role               = "roles/iam.serviceAccountUser"
  members            = var.members
}

# The custom role is for practicing the Principle of least privilege.
# The compute.projects.get permission on the project level is needed for enabling instance level OS Login.
# The predefined roles grant additional permissions that are not needed.

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
resource "google_project_iam_member" "bastion_os_login" {
  count = var.enable_os_login ? 1 : 0

  project = var.project
  role    = "projects/${var.project}/roles/${google_project_iam_custom_role.compute_os_login_viewer.0.role_id}"
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam_custom_role
resource "google_project_iam_custom_role" "compute_os_login_viewer" {
  count = var.enable_os_login ? 1 : 0

  project     = var.project
  role_id     = "osLoginProjectGet_${random_id.suffix.hex}"
  permissions = [ "compute.projects.get" ]
  title       = "OS Login Project Get Role"
  description = "The custom role for more fine-grained scoping of permissions."
}

# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id
resource "random_id" "suffix" {
  byte_length = 4
}
