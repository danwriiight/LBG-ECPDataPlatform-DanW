resource "google_container_cluster" "gke" {
  name     = var.name
  location = var.location

  deletion_protection = false

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  ip_allocation_policy {}

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.master_cidr
  }

  master_authorized_networks_config {}
}

resource "google_container_node_pool" "primary" {
  name = "primary-pool"
  cluster = google_container_cluster.gke.name
  location = var.location

  node_config {
    machine_type = var.machine_type
    service_account = var.node_service_account
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  autoscaling {
      min_node_count = 1
      max_node_count = 3
    }
}