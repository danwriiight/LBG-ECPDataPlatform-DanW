resource "google_bigquery_dataset" "dataset" {
dataset_id = var.dataset_id
location = var.location
delete_contents_on_destroy = false
default_table_expiration_ms = 1209600000 # 14 days
}