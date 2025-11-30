# envs/dev/variables.tf
variable "project_id" {
  type = string
  default = "lbg-ecpdataplatform"
}

variable "region" {
  type    = string
  default = "europe-west2"
}

variable "env" {
  type    = string
  default = "dev"
}

# variable "service_accounts" {
#   type = map(string)
# }
