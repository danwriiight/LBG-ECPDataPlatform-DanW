variable "name" {}
variable "display_name" {}
variable "project_id" {}
variable "roles" {
type = set(string)
}

variable "ksa_binding" {
  type        = object({
    namespace = string
    ksa_name  = string
    project   = string
  })
  default     = null
  description = "Optional: Bind this SA to a Kubernetes Service Account via Workload Identity."
}
