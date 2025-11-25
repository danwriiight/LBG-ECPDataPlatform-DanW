terraform {
  backend "gcs" {
    bucket = "tf-state-ecp-data-platform"
    prefix = "envs/dev"
  }
}