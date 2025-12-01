import json
import os
import time
import random
import logging
from datetime import datetime

from google.cloud import storage
from google.cloud import bigquery
from google.cloud import pubsub_v1


# -------------------------------
#        ENVIRONMENT VARS
# -------------------------------

print("Starting data processing application... loading environment variables")

PROJECT_ID = os.environ["PROJECT_ID"]
SUBSCRIPTION_ID = os.environ["SUBSCRIPTION_ID"]
BUCKET_NAME = os.environ["BUCKET_NAME"]
BIGQUERY_DATASET = os.environ["BIGQUERY_DATASET"]
BIGQUERY_TABLE = os.environ["BIGQUERY_TABLE"]

print(f"PROJECT_ID={PROJECT_ID}")
print(f"SUBSCRIPTION_ID={SUBSCRIPTION_ID}")
print(f"BUCKET_NAME={BUCKET_NAME}")
print(f"BIGQUERY: {BIGQUERY_DATASET}.{BIGQUERY_TABLE}")

# -------------------------------
#   TEST ERROR FOR ALERTING
# -------------------------------
logging.error("TEST ALERT: Intentional test error on startup to validate logging pipeline")

# -------------------------------
#       LOAD WORD LIST
# -------------------------------

def load_words():
    """Load word list from words.txt; required for readable message IDs."""
    words_path = os.path.join(os.path.dirname(__file__), "words.txt")

    print(f"Loading word list from: {words_path}")

    if not os.path.exists(words_path):
        raise FileNotFoundError("words.txt not found. Ensure it is included in the Docker image or mounted via ConfigMap.")

    with open(words_path, "r") as f:
        words = [line.strip() for line in f.readlines() if line.strip()]

    print(f"Loaded {len(words)} words for message ID generation.")
    return words


WORDS = load_words()


# -------------------------------
#        GCP CLIENTS
# -------------------------------

print("Initialising GCP clients (Storage, BigQuery, Pub/Sub)...")

storage_client = storage.Client()
bucket = storage_client.bucket(BUCKET_NAME)

bq_client = bigquery.Client()
table_ref = bq_client.dataset(BIGQUERY_DATASET).table(BIGQUERY_TABLE)

print("GCP clients initialised successfully.")


# -------------------------------
#        CRITICAL FIELDS
# -------------------------------

CRITICAL_FIELDS = [
    "sensor_id",
    "device_status",
    "temperature",
    "humidity",
    "pressure",
    "battery",
    "timestamp",
    "location",
    "signal_strength"
]


# -------------------------------
#        UTILITY HELPERS
# -------------------------------

def generate_message_id():
    """Human-readable ID: three random words."""
    return "-".join(random.choice(WORDS) for _ in range(3))


# -------------------------------
#        STORAGE HELPERS
# -------------------------------

def write_raw_to_gcs(message_dict, msg_id):
    filename = f"raw-{msg_id}.json"
    print(f"[{msg_id}] Writing RAW file to GCS as {filename}...")
    blob = bucket.blob(f"raw/{filename}")
    blob.upload_from_string(json.dumps(message_dict))
    print(f"[{msg_id}] RAW file written.")
    return True


def write_processed_to_gcs(processed_record, msg_id):
    filename = f"processed-{msg_id}.json"
    print(f"[{msg_id}] Writing PROCESSED file to GCS as {filename}...")
    blob = bucket.blob(f"processed/{filename}")
    blob.upload_from_string(json.dumps(processed_record))
    print(f"[{msg_id}] PROCESSED file written.")
    return True


# -------------------------------
#        CLEANING HELPERS
# -------------------------------

def normalise_value(value, to_type=float):
    try:
        if value is None:
            return None
        return to_type(value)
    except Exception:
        return None


def clean_status(status):
    if not status:
        return None
    s = str(status).strip().lower()
    if s in ["ok", "good", "healthy", "available"]:
        return "OK"
    if s == "warning":
        return "WARNING"
    if s == "error":
        return "ERROR"
    return None


def clean_battery(value):
    if not value:
        return None
    v = str(value).lower()
    if v == "low":
        return "LOW"
    if v in ["med", "medium"]:
        return "MEDIUM"
    if v == "high":
        return "HIGH"
    return None


def process_record(raw):
    return {
        "message_id": raw.get("message_id"),
        "sensor_id": raw.get("sensorId"),
        "device_status": clean_status(raw.get("device_status")),
        "temperature": normalise_value(raw.get("temp")),
        "humidity": normalise_value(raw.get("humidity")),
        "pressure": normalise_value(raw.get("pressure"), int),
        "battery": clean_battery(raw.get("battery")),
        "timestamp": raw.get("ts"),
        "location": raw.get("location"),
        "signal_strength": normalise_value(raw.get("signal"), int),
        "processed_at": datetime.utcnow().isoformat()
    }


# -------------------------------
#        VALIDATION LOGIC
# -------------------------------

def is_incomplete(processed):
    return any(processed.get(f) is None for f in CRITICAL_FIELDS)


# -------------------------------
#        BIGQUERY WRITER
# -------------------------------

def write_to_bigquery(record):
    print(f"[{record['message_id']}] Inserting into BigQuery...")
    errors = bq_client.insert_rows_json(table_ref, [record])
    if errors:
        print(f"[{record['message_id']}] BigQuery insert errors: {errors}")
        return False
    print(f"[{record['message_id']}] Inserted into BigQuery.")
    return True


# -------------------------------
#        PUBSUB CALLBACK
# -------------------------------

def callback(message):
    msg_id = generate_message_id()
    print(f"[{msg_id}] Received Pub/Sub message")

    try:
        raw_json = json.loads(message.data.decode("utf-8"))
        raw_json["message_id"] = msg_id

        print(f"[{msg_id}] Writing raw data...")
        write_raw_to_gcs(raw_json, msg_id)

        print(f"[{msg_id}] Cleaning and normalising fields...")
        processed = process_record(raw_json)

        print(f"[{msg_id}] Validating message fields...")
        if is_incomplete(processed):
            print(f"[{msg_id}] Skipped due to incomplete data.")
            message.ack()
            return

        print(f"[{msg_id}] Writing processed data...")
        write_processed_to_gcs(processed, msg_id)

        print(f"[{msg_id}] Writing to BigQuery...")
        write_to_bigquery(processed)

        message.ack()
        print(f"[{msg_id}] Successfully processed message.")

    except Exception as e:
        print(f"[{msg_id}] ERROR: {e}")
        message.nack()


# -------------------------------
#            MAIN LOOP
# -------------------------------

def main():
    print("Initialising Pub/Sub subscription listener...")
    subscriber = pubsub_v1.SubscriberClient()
    subscription_path = subscriber.subscription_path(PROJECT_ID, SUBSCRIPTION_ID)

    print(f"Listening for messages on {subscription_path}")
    subscriber.subscribe(subscription_path, callback=callback)

    heartbeat = 0
    while True:
        time.sleep(5)
        heartbeat += 1
        print(f"[HEARTBEAT] App alive and listening... ({heartbeat})")


if __name__ == "__main__":
    main()
