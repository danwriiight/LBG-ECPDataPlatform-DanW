output "enabled_services" {
  description = "List of enabled project services"
  value = [
    google_project_service.compute.service,
    google_project_service.container.service,
    google_project_service.iam.service,
    google_project_service.bigquery.service,
    google_project_service.pubsub.service,
    google_project_service.storage.service,
    google_project_service.logging.service,
    google_project_service.monitoring.service,
    google_project_service.artifact_registry.service
  ]
}
