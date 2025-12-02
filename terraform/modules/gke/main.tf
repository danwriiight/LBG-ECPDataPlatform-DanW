# GKE cluster definition
resource "google_container_cluster" "gke" {
  name     = var.name
  location = var.location

  deletion_protection = false # Allow terraform destroy

  # Remove default node pool to manage node pools explicitly
  remove_default_node_pool = true
  initial_node_count       = 1

  # Networking configuration
  network    = var.network
  subnetwork = var.subnetwork

  # Automatically assign pod and service CIDRs
  ip_allocation_policy {}

  # Use the regular release channel for cluster upgrades
  release_channel {
    channel = "REGULAR"
  }

  # Enable Workload Identity for secure pod-to-GCP identity mapping
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

# -----------------------------------------------------------
  # PRIVATE CLUSTER: NODES PRIVATE, CONTROL PLANE PUBLIC
  # -----------------------------------------------------------
  private_cluster_config {
    enable_private_nodes    = true

    # Control plane MUST be public so GitLab SaaS can deploy.
    # TODO: For production, set this back to true and deploy a 
    #       GitLab Runner inside the VPC or restrict to GitLab IPs.
    enable_private_endpoint = false

    master_ipv4_cidr_block  = var.master_cidr
  }

  # -----------------------------------------------------------
  # MASTER AUTHORIZED NETWORKS (TEMPORARY OPEN)
  # -----------------------------------------------------------
  # This allows GitLab SaaS runners to access the GKE control plane.
  # TODO: Tighten this to GitLab runner CIDRs or remove if running
  #       a self-hosted runner inside the VPC.
  master_authorized_networks_config {
    cidr_blocks {
      display_name = "TEMP-OPEN-FOR-CI"
      cidr_block   = "0.0.0.0/0"
    }
  }
}

# Node pool for the cluster
resource "google_container_node_pool" "primary" {
  name = "primary-pool"
  cluster = google_container_cluster.gke.name
  location = var.location

  node_config {
    machine_type = var.machine_type
    service_account = var.node_service_account
    # Full cloud-platform scope; acceptable since Workload Identity is used
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  autoscaling {
      min_node_count = 1
      max_node_count = 3
    }
}