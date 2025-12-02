# Create a custom VPC network
resource "google_compute_network" "vpc" {
  name = var.name
  auto_create_subnetworks = false
}

# Create one or more subnets inside the VPC
resource "google_compute_subnetwork" "subnet" {
  for_each = var.subnets
  name = each.key
  ip_cidr_range = each.value.cidr
  region = each.value.region
  network = google_compute_network.vpc.id

  # Allow private resources to reach Google APIs without public IPs
  private_ip_google_access = true
}