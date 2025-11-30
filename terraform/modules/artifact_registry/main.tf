resource "google_artifact_registry_repository" "repo" {
  repository_id   = var.repository_id
  location        = var.location
  description     = var.description
  format          = "DOCKER"

  # Optional: cleanup policy (retention)
  docker_config {
    immutable_tags = false
  }
}
