# GitLab CI Pipeline README

This document explains how the `.gitlab-ci.yml` pipeline works for building and deploying the IoT Processor application to GKE, along with security considerations and recommended improvements.

## Overview

The pipeline consists of two stages:

1. **Build**
    - Builds a Docker image from the `data_processing` directory of the source repository.
    - Authenticates to Google Cloud Artifact Registry.
    - Pushes the built image.
2. **Deploy**
    - Applies Kubernetes manifests from the `k8s/` folder.
    - Updates the deployment to use the newly pushed Docker image.
    - Waits for rollout to complete.

The pipeline runs automatically when commits are pushed to the `main` branch.

---

## Pipeline Structure

### Stages
```
stages:
  - build
  - deploy
```

---

## Build Stage

### Key Responsibilities
- Install required tools.
- Clone the application repository.
- Build a Docker image.
- Authenticate to Google Artifact Registry.
- Push the image.

### Important Variables
- `IMAGE_NAME`: Name of the application image.
- `IMAGE_TAG`: Short SHA of the commit.
- `IMAGE_URI`: Full Artifact Registry image URI.
- `GCP_PROJECT_ID`: GCP project where the image is stored.
- `GCP_SA_JSON_FILE`: CI variable containing a service account key.

### Output
The build stage persists an environment file (`build.env`) containing:
```
IMAGE_URI=<artifact registry path>
```
This is used by the deploy stage.

---

## Deploy Stage

### Key Responsibilities
- Authenticate to Google Cloud.
- Retrieve credentials for the target GKE cluster.
- Apply Kubernetes manifests.
- Patch the deployment with the new image.
- Monitor rollout.

### Dependencies
The deploy job uses `needs:` to fetch the artifact output from the build stage.

---

## Security Best Practices in This Pipeline

This pipeline already incorporates several strong practices:

### 1. **Short-lived job artifacts**
Artifacts expire in one hour to reduce credential retention.

### 2. **Service account-based authentication**
Using `gcloud auth activate-service-account` ensures predictable identity and access control.

### 3. **Protected branch restrictions**
The pipeline runs only on `main`, preventing untrusted branches from deploying.

### 4. **Artifact Registry authentication using `gcloud`**
Avoids storing Docker login credentials.

### 5. **Declarative Kubernetes apply**
Manifests stored in version control increase auditability.

### 6. **Rollout monitoring**
`kubectl rollout status` ensures failed deployments halt the pipeline.

---

## Recommended Security Improvements

### 1. **Limit use of Docker-in-Docker**
Move toward:
- Cloud Build

Docker-in-Docker has elevated security risks.

### 2. **Pin Container Versions**
Replace `google/cloud-sdk:latest` with a specific version.

### 3. **Validate Kubernetes Manifests**
Consider adding `kubeval` or `kubeconform`.

---

## Recommended Pipeline Enhancements

### 1. **Merge Request Pipeline (PR Workflow)**
Add a pipeline that runs on Merge Requests and includes:
- Linting
- Static analysis
- Unit tests
- Docker build (without pushing)
- Deployment dry-run (e.g. `kubectl apply --server-dry-run`)

### 2. **Security Scanning**
Add GitLab security templates:
```
include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Container-Scanning.gitlab-ci.yml
  - template: Security/Dependency-Scanning.gitlab-ci.yml
```

### 3. **IaC Scanning**
If Terraform or Kubernetes manifests are present:
- Add **tfsec** or **Checkov**.
- Add **kube-score**, **kubeaudit**, or **OPA Gatekeeper policies**.

### 4. **Image Vulnerability Scans**
Integrate Trivy:
```
trivy image --exit-code 1 "$IMAGE_URI"
```

### 5. **Smoke Tests Post-deployment**
After rollout:
- call a health endpoint
- test basic functionality

### 6. **Environment Promotion Workflow**
Use protected tags such as:
- `v1.0.0` -> triggers production deployment
- `staging-*` -> triggers staging deployment

### 7. **Add Observability Checks**
Pipeline jobs could verify:
- GKE pod health
- Logs for startup errors
- Horizontal Pod Autoscaler status

---

## Running the Pipeline Manually

1. Go to **CI/CD > Pipelines**.
2. Select **Run Pipeline**.
3. Choose the branch.
4. Provide optional variables (if needed).
5. Trigger.

Deployment jobs that require manual approval will show a play button.

---

## Summary

This GitLab CI pipeline provides a clear and effective workflow for building and deploying a Dockerised application to GKE. It adheres to key best practices and can be extended with additional security and operational enhancements.

If you want a version tailored for additional environments or a multi-tenant deployment model, let me know.

