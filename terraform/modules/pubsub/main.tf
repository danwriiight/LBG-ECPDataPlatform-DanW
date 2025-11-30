resource "google_pubsub_topic" "topic" {
  name    = "${var.project_id}-${var.env}-iot-topic"
  project = var.project_id
}

resource "google_pubsub_subscription" "subscription" {
  name  = "${google_pubsub_topic.topic.name}-sub"
  topic = google_pubsub_topic.topic.name

  ack_deadline_seconds        = 20
  message_retention_duration  = "86400s" # 1 day
  retain_acked_messages       = false

  expiration_policy {
    ttl = "" # never expire
  }
}