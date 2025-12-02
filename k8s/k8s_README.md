# Kubernetes Manifests for IoT Processor

This directory contains the Kubernetes resources required to deploy the **IoT Processor** application on GKE Autopilot.  
It includes:

- `deployment.yaml` – controls the application Deployment
- `consumer-sa.yaml` – defines the Kubernetes Service Account bound to a GCP IAM SA
- `configmap.yaml` – supplies environment configuration to the workload

---

## Deployment Overview

### deployment.yaml
The Deployment runs **two replicas** of the IoT Processor and pulls its container image from Artifact Registry.

Key features:
- Uses a dedicated Kubernetes Service Account (`consumer-sa`)
- Loads environment variables using `envFrom` referencing the ConfigMap
- Resource requests and limits applied for predictable performance
- Graceful shutdown via a `preStop` hook to avoid message loss
- ImagePullPolicy set to **Always** ensuring fresh image pulls during updates

### consumer-sa.yaml
Defines the Kubernetes Service Account with an annotation binding it to a **GCP Workload Identity** service account.

This enables secure access to:
- Pub/Sub
- GCS
- BigQuery

### configmap.yaml
Holds environment configuration values including project, topic, and BigQuery settings.

These values are injected as environment variables into the IoT Processor container.

---

## Common Kubernetes Commands

### Get Pods
```
kubectl get pods -n default
```

### View Pod Logs
```
kubectl logs <pod-name> -n default
```

Stream logs:
```
kubectl logs -f <pod-name> -n default
```

View logs for all replicas:
```
kubectl logs -l app=iot-processor -n default --prefix
```

### Restart Deployment (forces rollout)
```
kubectl rollout restart deployment/iot-processor -n default
```

### Check Deployment Rollout Status
```
kubectl rollout status deployment/iot-processor -n default
```

### Describe Pod (for debugging)
```
kubectl describe pod <pod-name> -n default
```

### Apply all manifests
```
kubectl apply -f .
```

### Delete resources
```
kubectl delete -f .
```

---

## Security Best Practices Implemented

### ✔ Workload Identity enabled
`consumer-sa.yaml` includes:
```
iam.gke.io/gcp-service-account: dev-gke-consumer@lbg-ecpdataplatform.iam.gserviceaccount.com
```
This avoids using service account keys and provides **secure, short-lived identity** for GCP access.

### ✔ Config stored in ConfigMap (no secrets)
Non-sensitive configuration is externalised via ConfigMaps, avoiding hardcoding values.

### ✔ Resource requests and limits defined
This prevents noisy-neighbour issues and enforces resource guarantees.

### ✔ Graceful shutdown hook
Avoids message loss when scaling down or restarting.

---

## Security Improvements (Recommended)

### 1. Add Liveness & Readiness Probes
Currently disabled.  
Replacing with a simple HTTP or TCP probe improves resiliency.

### 2. Move sensitive configs to Secrets
If the application later requires keys or credentials, use:
```
kubectl create secret generic <name> --from-literal=...
```

### 3. Network Policies
Restrict pod communication to only required services.

### 4. Pod Security Standards (PSS)
Enforce restricted security profiles:
- non-root execution
- read-only root filesystem
- dropped capabilities

### 5. No public image pulls
Ensure all images are stored in Artifact Registry only.

---

## Future Enhancements

- Add Horizontal Pod Autoscaler (HPA)
- Add health endpoint to container to support probes
- Add monitoring alerts for:
  - container restart count
  - error logs
  - autoscaling thresholds
- Add CI/CD deployment pipeline (GitLab or Cloud Build)

---

## Directory Structure
```
k8s/
 ├── deployment.yaml
 ├── consumer-sa.yaml
 └── configmap.yaml
```

---

## Notes
This directory is suitable for both:
- Manual `kubectl apply`
- Automated GitOps / CI/CD workflows

For improvements or questions, update this README accordingly.
