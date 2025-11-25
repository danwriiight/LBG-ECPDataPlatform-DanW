variable "name" {
type = string
}


variable "subnets" {
type = map(object({ cidr = string, region = string }))
}


## modules/vpc/outputs.tf
output "vpc_id" {
value = google_compute_network.vpc.id
}


output "subnets" {
value = google_compute_subnetwork.subnet
}