# GitLab CI Pipeline README

This document explains how the `.gitlab-ci.yml` pipeline works for
linting, testing, building and deploying the IoT Processor application
to GKE, along with security considerations and recommended improvements.

## Overview

The pipeline consists of four stages:

1.  **Lint**\
    Performs static code quality checks on the `data_processing`
    application code using Flake8.

2.  **Test**\
    Installs dependencies and runs unit tests using Pytest.

3.  **Build**\
    Builds and pushes a Docker image to Google Artifact Registry.

4.  **Deploy**\
    Applies Kubernetes manifests and deploys the new image to GKE.

The pipeline runs automatically when commits are pushed to the `main`
branch, and the lint/test stages also run on Merge Requests.

------------------------------------------------------------------------

## Pipeline Structure

### Stages

    stages:
      - lint
      - test
      - build
      - deploy

------------------------------------------------------------------------

## Lint Stage

### Purpose

The lint stage enforces Python style and code quality standards using
Flake8.

### Key Responsibilities

-   Install Flake8.
-   Clone the repository.
-   Run lint checks on the `data_processing` directory.
-   Fail the job if rules are violated.

### Trigger Conditions

Runs on: - Merge Requests - `main` branch

------------------------------------------------------------------------

## Test Stage

### Purpose

The test stage runs unit tests to validate application logic before
build and deployment.

### Key Responsibilities

-   Install project dependencies.
-   Install Pytest.
-   Execute test suite under `repo/data_processing/tests`.

### Trigger Conditions

Runs on: - Merge Requests - `main` branch

------------------------------------------------------------------------

## Build Stage

### Key Responsibilities

-   Install required tools.
-   Clone the application repository.
-   Build a Docker image from the `data_processing` directory.
-   Authenticate to Google Artifact Registry.
-   Push the tagged image.

### Important Variables

-   `IMAGE_NAME`: Name of the application image.
-   `IMAGE_TAG`: Short SHA of the commit.
-   `IMAGE_URI`: Full Artifact Registry image URI.
-   `GCP_PROJECT_ID`: GCP project where the image is stored.
-   `GCP_SA_JSON_FILE`: CI variable containing a service account key.

### Output

The build stage produces a `build.env` file containing:

    IMAGE_URI=<artifact registry path>

This is consumed by the deploy stage.

------------------------------------------------------------------------

## Deploy Stage

### Key Responsibilities

-   Authenticate to Google Cloud.
-   Retrieve credentials for the GKE cluster.
-   Apply Kubernetes manifests under `k8s/`.
-   Update the deployment with the new Docker image.
-   Wait for rollout completion.

### Dependencies

Uses the `needs:` keyword to fetch the build stage artifact.

------------------------------------------------------------------------

## Security Best Practices in This Pipeline

### 1. Short-lived job artifacts

Artifacts expire after one hour, reducing risk of credential leakage.

### 2. Service account-based authentication

Credentials scoped to specific GCP permissions improve security.

### 3. Protected branch enforcement

The deployment pipeline only runs on `main`.

### 4. Artifact Registry authentication using `gcloud`

Avoids baked-in Docker credentials.

### 5. Declarative Kubernetes applies

Ensures changes are traceable and auditable.

### 6. Rollout monitoring

Halts deployment on failed rollouts.

------------------------------------------------------------------------

## Recommended Security Improvements

### 1. Reduce Docker-in-Docker usage

Consider Cloud Build or BuildKit for improved security.

### 2. Pin base image versions

Avoid `:latest` tags to prevent unexpected behaviour.

### 3. Validate Kubernetes manifests

Introduce tools such as: - kubeval - kubeconform

------------------------------------------------------------------------

## Recommended Pipeline Enhancements

### 1. Merge Request pipeline improvements

Add: - Additional linters - Static analysis - Dependency checks -
Deployment server-side dry-run

### 2. Security scanning

GitLab templates:

    include:
      - template: Security/SAST.gitlab-ci.yml
      - template: Security/Container-Scanning.gitlab-ci.yml
      - template: Security/Dependency-Scanning.gitlab-ci.yml

### 3. IaC scanning

Suitable for Terraform and Kubernetes environments: - tfsec / Checkov -
kube-score, kubeaudit

### 4. Image vulnerability scanning

Integrate Trivy:

    trivy image --exit-code 1 "$IMAGE_URI"

### 5. Post-deployment smoke tests

Validate: - health endpoints - basic functionality

### 6. Environment promotion workflow

Tag-based deployments for multi-env promotion.

### 7. Add observability checks

Examples: - Pod health - Startup logs - HPA coverage

------------------------------------------------------------------------

## Running the Pipeline Manually

1.  Go to CI/CD \> Pipelines.
2.  Select Run Pipeline.
3.  Choose a branch.
4.  Provide optional variables.
5.  Trigger the run.

Manual approval steps will appear where configured.

------------------------------------------------------------------------

## Summary

This CI pipeline provides a comprehensive workflow that covers code
quality validation, testing, container build, and deployment to GKE. It
follows strong security principles and can be further enhanced with
additional scanning, multi-environment workflows and validation steps.
