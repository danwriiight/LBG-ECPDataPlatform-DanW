# Configure Terraform to store its state file in Google Cloud Storage (GCS)
terraform {
  backend "gcs" {
    bucket = "tf-state-ecp-data-platform"
    prefix = "envs/dev"
  }
}