variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "project_id" {
  type = string
}

variable "service_accounts" {
  type        = map(string)
  description = "Map of service accounts needing KMS key access"
}


