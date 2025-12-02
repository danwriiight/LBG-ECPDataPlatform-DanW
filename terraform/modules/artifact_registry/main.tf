# Artifact Registry repository module for storing container images
resource "google_artifact_registry_repository" "repo" {
  repository_id   = var.repository_id
  # Region where the registry is hosted
  location        = var.location
  description     = var.description
  # Store Docker container images
  format          = "DOCKER"

  # Docker specific configuration
  docker_config {
    # Allow retagging and overwriting images (set to true for immutable tags)
    immutable_tags = false
  }
}
