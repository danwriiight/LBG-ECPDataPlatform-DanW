# VPC module creating the main network and subnets
module "vpc" {
  source = "../../modules/vpc"

  # VPC name formatted with project and environment
  name = "${var.project_id}-${var.env}-vpc"
  # Define private subnet for the GKE cluster
  subnets = {
      "${var.env}-gke-private-subnet"= { cidr = "10.0.1.0/24", region = var.region } #256 addresses
    }
}

# GKE cluster module
module "gke" {
  source = "../../modules/gke"
  name = "${var.project_id}-${var.env}-gke"
  location = var.region
  network = module.vpc.vpc_id
  subnetwork = module.vpc.subnets["${var.env}-gke-private-subnet"].id

  # Control plane CIDR block for private GKE cluster
  # Consider aligning with wider platform standards
  master_cidr = "172.16.0.0/28"

  project_id = var.project_id
  node_service_account = module.node_sa.service_account_email
}

# Node pool service account used by GKE nodes
module "node_sa" {
  source = "../../modules/iam"
  name = "${var.env}-gke-node"
  display_name = "GKE Node SA"
  project_id = var.project_id

  # IAM permissions required for GKE nodes to operate correctly
  roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/storage.objectViewer",
    "roles/artifactregistry.reader"

  ]
}

# Workload Identity service account used by the IoT consumer workload
module "consumer_sa" {
  source       = "../../modules/iam"
  name         = "${var.env}-gke-consumer"
  display_name = "GKE Workload Consumer SA"
  project_id   = var.project_id

  # Permissions required for consuming IoT messages and writing results
  roles = [
    "roles/pubsub.subscriber",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/storage.objectAdmin"
  ]

  # Bind IAM SA to Kubernetes SA for Workload Identity
  ksa_binding = {
    namespace = "default"
    ksa_name  = "consumer-sa"
    project   = var.project_id
  }
}

# Service account used by the message publisher component
module "producer_sa" {
  source       = "../../modules/iam"
  name         = "${var.env}-pubsub-producer"
  display_name = "Pub/Sub Producer SA"
  project_id   = var.project_id

  roles = [
    "roles/pubsub.publisher"
  ]
}

# Service account used by CI/CD system (GitLab) for deployments
module "cicd_sa" {
  source       = "../../modules/iam"
  name         = "${var.env}-cicd-deployer"
  display_name = "GitLab CI Deployer SA"
  project_id   = var.project_id

  roles = [
  "roles/storage.admin",
  "roles/container.developer",
  "roles/container.clusterViewer",
  "roles/artifactregistry.writer"
  ]

}

# GCS bucket for raw and processed IoT data
module "bucket" {
  source   = "../../modules/storage"
  name     = "${var.project_id}-${var.env}-data-bucket"
  location = var.region
}

# Artifact Registry for storing IoT processor container images
module "artifact_repo" {
  source        = "../../modules/artifact_registry"
  repository_id = "iot-processor-repo"
  location      = var.region        # e.g. europe-west2
  description   = "Docker repository for IoT processor application"
}

# BigQuery dataset for storing processed IoT records
module "dataset" {
  source = "../../modules/bigquery"
  dataset_id = "${var.env}_dataset"
  location = var.region
}

# Pub/Sub topics and subscriptions for IoT message flow
module "pubsub" {
  source     = "../../modules/pubsub"
  project_id = var.project_id
  env        = var.env
}

# Cloud NAT module to allow private GKE nodes to reach the internet
module "nat" {
  source = "../../modules/nat"

  env     = var.env
  region  = var.region
  vpc_id  = module.vpc.vpc_id
}
