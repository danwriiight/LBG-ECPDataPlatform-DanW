resource "google_storage_bucket" "bucket" {
name = var.name
location = var.location
force_destroy = false

uniform_bucket_level_access = true

versioning {
  enabled = true
  }

lifecycle_rule {
    action { 
      type = "Delete" 
      }
    condition {
      age = 90 
      }
  }
}