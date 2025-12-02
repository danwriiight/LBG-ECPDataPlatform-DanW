# Pub/Sub topic for IoT message ingestion
resource "google_pubsub_topic" "topic" {
  name    = "${var.project_id}-${var.env}-iot-topic"
  project = var.project_id
}

# Subscription for consuming IoT messages
resource "google_pubsub_subscription" "subscription" {
  name  = "${google_pubsub_topic.topic.name}-sub"
  topic = google_pubsub_topic.topic.name

  # Amount of time subscriber has to acknowledge a message
  ack_deadline_seconds        = 20

  # How long to retain unacknowledged messages
  message_retention_duration  = "86400s" # 1 day

  # Do not store acked messages
  retain_acked_messages       = false

  # Prevent the subscription from auto expiring
  expiration_policy {
    ttl = "" # never expire
  }
}