resource "google_kms_key_ring" "data" {
  name     = "${var.env}-data-keyring"
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "data_key" {
  name            = "${var.env}-data-key"
  key_ring        = google_kms_key_ring.data.id
  rotation_period = "2592000s" # 30 days
}

# Grant CMEK encrypt/decrypt to all service accounts passed in
resource "google_kms_crypto_key_iam_member" "service_accounts" {
  for_each      = toset(var.service_accounts)
  crypto_key_id = google_kms_crypto_key.data_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${each.value}"
}
