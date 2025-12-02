import json
import logging
import random
import time
from google.cloud import pubsub_v1

from config import PROJECT_ID, TOPIC_ID, MESSAGE_COUNT
from generator import generate_raw_message

# Set up simple structured logging for visibility of publish operations
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s"
)

# Publish synthetic IoT messages to a Pub/Sub topic


def publish_messages():
    """
    Publishes randomly generated IoT messages using the PublisherClient.
    Includes logging, small delays to mimic streaming behaviour, and basic error handling.
    """
    logging.info("Starting Pub/Sub publisher...")
    
    # Create Pub/Sub publisher client
    publisher = pubsub_v1.PublisherClient()

    # Fully qualified Pub/Sub topic path
    topic_path = publisher.topic_path(PROJECT_ID, TOPIC_ID)
    logging.info(f"Publishing to: {topic_path}")

    # Iterate through number of desired messages
    for i in range(MESSAGE_COUNT):
        try:
            # Generate a messy IoT message
            message_dict = generate_raw_message()
            # Convert to JSON bytes (required by Pub/Sub)
            message_bytes = json.dumps(message_dict).encode("utf-8")
            # Publish message and wait for completion
            future = publisher.publish(topic_path, message_bytes)
            future.result()  

            logging.info(f"Published message {i+1}/{MESSAGE_COUNT}: {message_dict}")

            # Sleep briefly to simulate realistic streaming intervals
            time.sleep(random.uniform(0.1, 0.4))

        except Exception as e:
            logging.error(f"Error publishing message {i+1}: {e}")

    logging.info("Finished publishing synthetic IoT messages.")

if __name__ == "__main__":
    publish_messages()
