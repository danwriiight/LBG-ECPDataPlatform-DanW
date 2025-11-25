variable "name" {}
variable "location" {}
variable "network" {}
variable "subnetwork" {}
variable "project_id" {}
variable "master_cidr" {}
variable "machine_type" { default = "e2-standard-4" }
variable "node_service_account" {}