# Google Cloud Storage bucket module
resource "google_storage_bucket" "bucket" {
name = var.name
location = var.location
force_destroy = false

# Enforce IAM-only permissions (no legacy ACLs)
uniform_bucket_level_access = true

# Enable object versioning to retain older versions of files
versioning {
  enabled = true
  }

# Lifecycle rule to automatically delete objects older than 90 days
lifecycle_rule {
    action { 
      type = "Delete" 
      }
    condition {
      age = 90 
      }
  }
}