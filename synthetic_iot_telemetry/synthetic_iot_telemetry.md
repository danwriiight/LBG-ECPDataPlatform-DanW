# Synthetic IoT Telemetry Generator

This directory contains a small synthetic IoT telemetry generator used to publish intentionally messy, schema-drifting IoT messages into a Google Pub/Sub topic.  
It is designed to feed the *IoT Processor* application running in GKE.

---

## 📁 Files Overview

### **config.py**
Stores configuration values:

- `PROJECT_ID` – GCP project  
- `TOPIC_ID` – Pub/Sub topic ID  
- `MESSAGE_COUNT` – number of messages to publish

Configuration values are intentionally simple.  
In production, these should be externalised (see security section below).

---

### **generator.py**
Contains the function:

```
generate_raw_message()
```

This produces **intentionally inconsistent and messy IoT messages** to simulate real-world sensor drift:

- Randomised string/number formats  
- Inconsistent casing  
- Random missing fields  
- Mixed string and numeric types  
- Non-standard timestamps  

This is useful for testing:
- Your data cleaning logic  
- Schema evolution robustness  
- Error handling paths  
- BigQuery ingestion rules  

---

### **publish.py**
Publishes messages to Pub/Sub using the official `google-cloud-pubsub` client.

Key behaviours:
- Logs each published event
- Generates a fresh message for each iteration
- Introduces slight delays to mimic real streaming telemetry
- Catches and logs individual publish errors
- Uses a synchronous future to ensure message persistence before continuing

---

## 🚀 Running the Telemetry Generator

### 1. Authenticate to GCP
Ensure you have gcloud installed and authenticated:

```
gcloud auth login
gcloud auth application-default login
```

Or, if running on Cloud Shell, you're already authenticated.

---

### 2. Install dependencies
```
pip install google-cloud-pubsub
```

---

### 3. Run the publisher
```
python3 publish.py
```

This will send `MESSAGE_COUNT` messages to your configured Pub/Sub topic.

---

## 🔧 Useful Modifications

### Change number of messages
Edit `MESSAGE_COUNT` in `config.py`:

```
MESSAGE_COUNT = 500
```

### Change topic
Update:

```
TOPIC_ID = "<your-topic>"
```

---

## 🧪 Verifying Messages

### View messages published in Pub/Sub
```
gcloud pubsub subscriptions pull <subscription> --auto-ack --limit=5
```

### Or watch logs in GKE (IoT Processor pod)
```
kubectl logs -l app=iot-processor -n default --follow
```

---

## 🔐 Security Notes (Good Practices Already Used)

### ✔ No service account keys required
The publish script relies on **Application Default Credentials** (ADC), avoiding key files.

### ✔ No secrets in code
Only non-sensitive values are stored in `config.py`.  
Credentials are *never* hard-coded.

---

## Recommended Improvements

### 1. Avoid hardcoded configuration in `config.py`
Instead, use environment variables:

```
PROJECT_ID = os.getenv("PROJECT_ID")
TOPIC_ID = os.getenv("TOPIC_ID")
```

### 2. Provide a `.env.example` file
This helps developers set their environment consistently.

### 3. Wrap Pub/Sub client in retry-aware configuration
Enable exponential backoff / retry configuration for production-scale testing.

### 4. Add structured logging
Improves observability in Cloud Logging.

### 5. Add command-line flags
Allow users to override:
- message count  
- topic ID  
- sleep interval  
- message noise level  

---

## 📌 Common Commands

### Install dependencies
```
pip install -r requirements.txt
```

### Run publisher
```
python3 publish.py
```

### Quick test (one message)
```
python3 -c "from generator import generate_raw_message; print(generate_raw_message())"
```

---

## 📁 Directory Structure

```
synthetic_iot_telemetry/
 ├── config.py
 ├── generator.py
 └── publish.py
```

---

## 📝 Notes

This directory is safe to include in the repository and can be used for:

- Load testing  
- Schema drift simulation  
- Reproducing ingestion errors  
- CI pipelines  
- Development validation  

Update this README as you extend your generator (e.g., new fields, device types, or output formats).

