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
  type = list(string)
  description = "Service accounts that need access to the CMEK key"
}

