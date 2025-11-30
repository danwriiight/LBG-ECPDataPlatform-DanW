import json
import logging
import random
import time
from google.cloud import pubsub_v1

from config import PROJECT_ID, TOPIC_ID, MESSAGE_COUNT
from generator import generate_raw_message

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s"
)

def publish_messages():
    """
    Publishes synthetic IoT messages to a Pub/Sub topic.
    Includes logging, retry behaviour and graceful exits.
    """
    logging.info("Starting Pub/Sub publisher...")

    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(PROJECT_ID, TOPIC_ID)

    logging.info(f"Publishing to: {topic_path}")

    for i in range(MESSAGE_COUNT):
        try:
            message_dict = generate_raw_message()
            message_bytes = json.dumps(message_dict).encode("utf-8")

            future = publisher.publish(topic_path, message_bytes)
            future.result()  # wait for the write to complete

            logging.info(f"Published message {i+1}/{MESSAGE_COUNT}: {message_dict}")

            # Simulate streaming behaviour
            time.sleep(random.uniform(0.1, 0.4))

        except Exception as e:
            logging.error(f"Error publishing message {i+1}: {e}")

    logging.info("Finished publishing synthetic IoT messages.")

if __name__ == "__main__":
    publish_messages()
