# Create a Google Cloud service account
resource "google_service_account" "sa" {
  account_id = var.name
  display_name = var.display_name
}

# Assign IAM roles to the service account at the project level
resource "google_project_iam_member" "bindings" {
  for_each = var.roles
  project = var.project_id
  role = each.value
  # Bind role to this service account
  member = "serviceAccount:${google_service_account.sa.email}"
}

# Optional: Workload Identity binding between GKE KSA and this GCP SA
resource "google_service_account_iam_member" "wi_binding" {
  count  = var.ksa_binding == null ? 0 : 1
  service_account_id = google_service_account.sa.name
  role = "roles/iam.workloadIdentityUser" # Required for WI

  # Map Kubernetes SA to this Google SA
  member = "serviceAccount:${var.ksa_binding.project}.svc.id.goog[${var.ksa_binding.namespace}/${var.ksa_binding.ksa_name}]"
}
