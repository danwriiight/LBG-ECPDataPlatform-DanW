variable "repository_id" {
  type        = string
  description = "Name of the Artifact Registry repository"
}

variable "location" {
  type        = string
  description = "Region for the repository (e.g. europe-west2)"
}

variable "description" {
  type        = string
  description = "Description of the repository"
}
