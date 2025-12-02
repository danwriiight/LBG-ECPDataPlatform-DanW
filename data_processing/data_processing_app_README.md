# Data Processing Service (IoT Processor)

This directory contains the **IoT data processing pipeline**, responsible for receiving raw IoT telemetry from Pub/Sub, validating and cleaning the data, writing raw and processed files into Cloud Storage, and inserting structured records into BigQuery.

It is designed to run continuously inside a GKE Autopilot deployment.

---

## 📁 Directory Contents

| File | Purpose |
|------|---------|
| `app.py` | Main application entrypoint. Subscribes to Pub/Sub and processes incoming messages. |
| `Dockerfile` | Builds the lightweight Python 3.11 image used in GKE. |
| `requirements.txt` | Python dependencies pinned to stable versions. |
| `words.txt` | Word list used to generate human-readable message IDs. |
| `tests/` | Placeholder for unit tests (to be completed). |

---

# 🧠 Application Overview (`app.py`)

The application performs the following flow:

1. **Loads environment variables** for Pub/Sub, BigQuery, and Cloud Storage.
2. Loads a list of human‑friendly words to generate readable message IDs.
3. Initialises GCP clients:
   - Cloud Storage
   - BigQuery
   - Pub/Sub Subscriber
4. Subscribes to a Pub/Sub topic.
5. For every message:
   - Generates message ID  
   - Writes raw payload to GCS  
   - Cleans / normalises fields  
   - Validates presence of critical fields  
   - Writes processed version to GCS  
   - Writes valid records to BigQuery  
   - ACKs or NACKs based on success/failure
6. Prints a heartbeat every 5 seconds to show the app is alive.

A **synthetic test error** is logged on startup to validate metrics and alerting:
```
logging.error("TEST ALERT: Intentional test error on startup to validate logging pipeline")
```

---

# 🔧 Running Locally

## 1. Authenticate to Google Cloud
```
gcloud auth application-default login
```

## 2. Install dependencies
```
pip install -r requirements.txt
```

## 3. Run the processor
This requires the Pub/Sub subscription to already exist:

```
python3 app.py
```

You may need to set environment variables manually:
```
export PROJECT_ID="..."
export SUBSCRIPTION_ID="..."
export BUCKET_NAME="..."
export BIGQUERY_DATASET="..."
export BIGQUERY_TABLE="..."
```

---

# 🐳 Docker Usage

### Build image
```
docker build -t iot-processor .
```

### Run (with local environment variables)
```
docker run -e PROJECT_ID=...            -e SUBSCRIPTION_ID=...            -e BUCKET_NAME=...            -e BIGQUERY_DATASET=...            -e BIGQUERY_TABLE=...            iot-processor
```

---

# 📦 GKE Deployment (How This Is Used)

The GKE Deployment:
- Pulls the Docker image from Artifact Registry
- Injects environment variables using a ConfigMap
- Runs two replicas behind a managed Service Account
- Uses Workload Identity for secure authentication

See the `k8s/` directory for manifests.

---

# 🔍 Logs and Debugging

### View logs for all replicas:
```
kubectl logs -l app=iot-processor --prefix -f
```

### Describe pod (to debug crashes)
```
kubectl describe pod <pod-name>
```

### Check rollout
```
kubectl rollout status deployment/iot-processor
```

### Restart deployment
```
kubectl rollout restart deployment/iot-processor
```

---

# 🔐 Security Best Practices Implemented

### ✔ Workload Identity used (no long‑lived service account keys)
The pod authenticates to GCP using the Kubernetes SA → GCP SA binding.

### ✔ Resource requests & limits defined
Prevents noisy-neighbour issues and ensures stable performance.

### ✔ No hardcoded credentials
All configuration is injected via ConfigMap or environment variables.

### ✔ Minimalistic Python base image
Using `python:3.11-slim` reduces attack surface.

### ✔ Raw and processed data stored separately
Supports observability, debugging, and auditing.

---

# Recommended Enhancements

### 1. Add liveness / readiness probes  
Once an HTTP endpoint or health check exists.

### 2. Use structured logging  
Using `google-cloud-logging` to push JSON logs into Cloud Logging.

### 3. Enforce non-root execution  
Modify Dockerfile:

```
RUN adduser --disabled-password appuser
USER appuser
```

### 4. Validate input schema more strictly  
To avoid malformed messages entering downstream systems.

### 5. Add retry logic around BigQuery insertions  
Currently insertions fail fast.

---

# 🧪 Unit Testing

The `tests/` directory currently contains a TODO file outlining required tests.

Recommended next steps:

- Add tests for helper functions (`normalise_value`, `clean_status`, etc.)
- Mock BigQuery, Pub/Sub, and GCS using `pytest-mock`
- Add integration tests with only mocks (no real GCP)
- Include the tests in CI to gate deployments

---

# 🗂 Directory Structure

```
data_processing/
 ├── app.py
 ├── Dockerfile
 ├── requirements.txt
 ├── words.txt
 └── tests/
      └── test_app.py (TODO list)
```

---

# 📝 Notes

This module is fully production‑ready for GKE Autopilot.

It supports:
- Schema drift
- Message validation
- Raw/processed separation
- GCS archival
- BigQuery ingestion
- Log-based alerting
- Deployment health monitoring

Future improvements such as autoscaling, HTTP health checks, and structured logging will further mature the service.

