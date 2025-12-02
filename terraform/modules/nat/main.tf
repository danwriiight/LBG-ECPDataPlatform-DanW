# Cloud Router for managing NAT configuration
resource "google_compute_router" "nat_router" {
  name = "${var.env}-router"
  region = var.region
  network = var.vpc_id
}

# Cloud NAT for enabling outbound internet access for private GKE nodes
resource "google_compute_router_nat" "nat" {
  name = "${var.env}-nat"
  router = google_compute_router.nat_router.name
  region = var.region

  # Auto-assign external IPs used for NAT
  nat_ip_allocate_option = "AUTO_ONLY"

  # Apply NAT to all subnets and all IP ranges in the VPC
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # Enable NAT logging for debugging and visibility
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}