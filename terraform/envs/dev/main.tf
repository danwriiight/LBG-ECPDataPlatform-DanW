module "vpc" {
  source = "../../modules/vpc"
  name = "${var.project_id}-${var.env}-vpc"
  subnets = {
      "${var.env}-gke-private-subnet"= { cidr = "10.0.1.0/24", region = var.region } #256 addresses
    }
}

module "gke" {
  source = "../../modules/gke"
  name = "${var.project_id}-${var.env}-gke"
  location = var.region
  network = module.vpc.vpc_id
  subnetwork = module.vpc.subnets["${var.env}-gke-private-subnet"].id
  # TODO - Validate CIDR for GKE Control Plane
  master_cidr = "172.16.0.0/28"
  project_id = var.project_id
  node_service_account = module.node_sa.service_account_email
}

# module "gke_workload_sa" {
#   source       = "../../modules/iam"
#   name         = "${var.env}-gke-consumer"
#   display_name = "GKE Workload Consumer SA"
#   project_id   = var.project_id

#   roles = [
#     "roles/pubsub.subscriber",
#     "roles/bigquery.dataEditor",
#     "roles/bigquery.jobUser",
#     "roles/storage.objectAdmin",
#     "roles/secretmanager.secretAccessor"   # optional
#   ]
# }

module "node_sa" {
  source = "../../modules/iam"
  name = "${var.env}-gke-node"
  display_name = "GKE Node SA"
  project_id = var.project_id
  roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/storage.objectViewer"
  ]
}

module "consumer_sa" {
  source       = "../../modules/iam"
  name         = "${var.env}-gke-consumer"
  display_name = "GKE Workload Consumer SA"
  project_id   = var.project_id

  roles = [
    "roles/pubsub.subscriber",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/storage.objectAdmin"
  ]

  ksa_binding = {
    namespace = "default"
    ksa_name  = "consumer-sa"
    project   = var.project_id
  }
}

module "producer_sa" {
  source       = "../../modules/iam"
  name         = "${var.env}-pubsub-producer"
  display_name = "Pub/Sub Producer SA"
  project_id   = var.project_id

  roles = [
    "roles/pubsub.publisher"
  ]
}

module "bucket" {
  source   = "../../modules/storage"
  name     = "${var.project_id}-${var.env}-data-bucket"
  location = var.region
}

# module "kms" {
#   source      = "../../modules/kms"
#   env         = var.env
#   region      = var.region
#   project_id  = var.project_id

#   service_accounts = {
#   consumer = module.consumer_sa.service_account_email
#   node     = module.node_sa.service_account_email
#   }
# }

module "dataset" {
  source = "../../modules/bigquery"
  dataset_id = "${var.env}_dataset"
  location = var.region
}

module "pubsub" {
  source     = "../../modules/pubsub"
  project_id = var.project_id
  env        = var.env
}


# module "project_services" {
#   source     = "../../modules/project_services"
#   project_id = var.project_id
# }

module "nat" {
  source = "../../modules/nat"

  env     = var.env
  region  = var.region
  vpc_id  = module.vpc.vpc_id
}
