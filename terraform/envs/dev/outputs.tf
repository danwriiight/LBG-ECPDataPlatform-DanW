# -------------------------
# VPC OUTPUTS
# -------------------------

output "vpc_id" {
  description = "VPC network ID"
  value       = module.vpc.vpc_id
}

output "gke_subnet_id" {
  description = "Subnet ID used by the GKE cluster"
  value       = module.vpc.subnets["${var.env}-gke-private-subnet"].id
}

# -------------------------
# GKE OUTPUTS
# -------------------------

output "gke_cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke.name
}

# -------------------------
# SERVICE ACCOUNTS
# -------------------------

output "node_sa_email" {
  description = "Email address of the GKE node service account"
  value       = module.node_sa.service_account_email
}

output "consumer_sa_email" {
  description = "Email address of the consumer workload service account"
  value       = module.consumer_sa.service_account_email
}

output "producer_sa_email" {
  description = "Email address of the producer service account"
  value       = module.producer_sa.service_account_email
}

output "cicd_sa_email" {
  description = "Email address of the CI/CD deployer service account"
  value       = module.cicd_sa.service_account_email
}

# -------------------------
# STORAGE
# -------------------------

output "data_bucket_name" {
  description = "Name of the GCS bucket for IoT data"
  value       = module.bucket.name
}

# -------------------------
# ARTIFACT REGISTRY
# -------------------------

output "artifact_repo_id" {
  description = "Artifact Registry repo ID for IoT processor images"
  value       = module.artifact_repo.repository_id
}

# -------------------------
# BIGQUERY
# -------------------------

output "bigquery_dataset_id" {
  description = "BigQuery dataset used for IoT data"
  value       = module.dataset.dataset_id
}

# -------------------------
# PUBSUB
# -------------------------

output "pubsub_topic" {
  description = "IoT Pub/Sub topic name"
  value       = module.pubsub.topic
}

output "pubsub_subscription" {
  description = "IoT Pub/Sub subscription name"
  value       = module.pubsub.subscription
}

# -------------------------
# NAT
# -------------------------

output "nat_name" {
  description = "Cloud NAT instance name"
  value       = module.nat.name
}
