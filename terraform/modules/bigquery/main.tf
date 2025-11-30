resource "google_bigquery_dataset" "dataset" {
dataset_id = var.dataset_id
location = var.location
delete_contents_on_destroy = false
default_table_expiration_ms = 1209600000 # 14 days
}

resource "google_bigquery_table" "iot_table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "iot_table"

  schema = <<EOF
[
  {"name": "message_id",      "type": "STRING",   "mode": "REQUIRED"},
  {"name": "sensor_id",       "type": "STRING",   "mode": "REQUIRED"},
  {"name": "device_status",   "type": "STRING",   "mode": "REQUIRED"},
  {"name": "temperature",     "type": "FLOAT",    "mode": "REQUIRED"},
  {"name": "humidity",        "type": "FLOAT",    "mode": "REQUIRED"},
  {"name": "pressure",        "type": "INTEGER",  "mode": "REQUIRED"},
  {"name": "battery",         "type": "STRING",   "mode": "REQUIRED"},
  {"name": "timestamp",       "type": "STRING",   "mode": "REQUIRED"},
  {"name": "location",        "type": "STRING",   "mode": "REQUIRED"},
  {"name": "signal_strength", "type": "INTEGER",  "mode": "REQUIRED"},
  {"name": "processed_at",    "type": "TIMESTAMP","mode": "REQUIRED"}
]
EOF
}
