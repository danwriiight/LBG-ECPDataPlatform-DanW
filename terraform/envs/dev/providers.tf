# Google provider for managing GCP resources
provider "google" {
  project = var.project_id
  region  = var.region
}

# Google Beta provider for accessing preview or beta GCP features
provider "google-beta" {
  project = var.project_id
  region  = var.region
}