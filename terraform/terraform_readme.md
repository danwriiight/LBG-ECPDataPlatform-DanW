# Terraform Infrastructure Setup

This repository contains a modular Terraform configuration structured to support multiple environments and reusable modules. It follows infrastructure as code best practice while allowing manual deployment.

## Repository Structure

```
terraform/
├── envs/
│   └── dev/
│       ├── backend.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── variables.tf
│       └── versions.tf
└── modules/
    ├── artifact_registry/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── bigquery/
    ├── gke/
    ├── iam/
    ├── kms/
    ├── nat/
    ├── project_services/
    ├── pubsub/
    ├── storage/
    └── vpc/
```

### Environments
Each environment folder contains the Terraform configuration specific to that environment (e.g. dev in this case but could be extended to staging, prod). This includes the backend configuration, provider settings, input variables, and root module composition.

### Modules
The `modules` directory contains reusable Terraform modules that encapsulate individual components of the infrastructure such as VPC, IAM, GKE, Artifact Registry, BigQuery and more.

---

## Prerequisites

Before deploying, ensure the following are installed and configured:

- Terraform CLI (matching version in `versions.tf`)
- Google Cloud SDK
- Authenticated access to the relevant GCP project
- A remote backend (GCS bucket) created if using state storage

Authenticate with GCP:
```
gcloud auth application-default login
```

---

## Deployment Instructions

### 1. Navigate to the Environment
```
cd terraform/envs/dev
```

### 2. Initialise Terraform
This downloads provider plugins and initialises the backend.
```
terraform init
```

### 3. Validate the Configuration
```
terraform validate
```

### 4. Review the Planned Changes
```
terraform plan -out=plan.out
```

### 5. Apply the Infrastructure
```
terraform apply plan.out
```

### 6. View Outputs
```
terraform output
```

---

## Module Design

Each module follows these principles:
- **Input variables** defined in `variables.tf`
- **Resource definitions** in `main.tf`
- **Explicit outputs** in `outputs.tf`
- **No provider blocks inside modules** to maintain portability

Modules are referenced from the root `main.tf` using relative paths.

---

## State Management

Ensure the backend configuration in `backend.tf` points to the correct remote state bucket.

Example backend:
```
backend "gcs" {
  bucket = "<your-terraform-state-bucket>"
  prefix = "dev"
}
```

---

## CI/CD Pipeline - Next Steps

To automate deployments, consider the following roadmap:

### 1. Decide on CI/CD Platform
Common choices:
- GitHub Actions
- GitLab CI
- Terraform Cloud / Terraform Enterprise
- Google Cloud Build

### 2. Implement Pipeline Stages
- **Format**: `terraform fmt -check`
- **Lint**: Use `tflint` or `terraform validate`
- **Plan**: Generate and store plan as an artifact
- **Approval Step**: Manual or automated depending on environment
- **Apply**: Apply only on protected branches (e.g. main)

### 3. Secure Secrets and Credentials
- Use Workload Identity Federation or CI secrets management
- Avoid long‑lived service account keys

### 4. Add Environment Promotion
- dev -> staging -> prod controlled via pull requests and pipeline approvals

### 5. Add Policy as Code (Optional)
- Enforce guardrails using OPA or Terraform Cloud Sentinel

---

## Future Enhancements
- Introduce automated testing with Terratest
- Integrate cost estimation tools such as Infracost

---

If you need help implementing the CI/CD pipeline or adjusting the module structure, feel free to ask.

