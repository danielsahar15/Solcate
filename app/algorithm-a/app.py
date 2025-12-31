import json
import logging
import os
import pika
import time

logging.basicConfig(level=logging.INFO)

RABBIT_HOST = os.getenv("RABBIT_HOST")
RABBIT_USER = os.getenv("RABBIT_USER")
RABBIT_PASS = os.getenv("RABBIT_PASS")

INPUT_QUEUE = "audio"
OUTPUT_QUEUE = "features"


def connect():
    creds = pika.PlainCredentials(RABBIT_USER, RABBIT_PASS)
    params = pika.ConnectionParameters(RABBIT_HOST, credentials=creds)
    return pika.BlockingConnection(params)


def process_message(ch, method, properties, body):
    msg = json.loads(body)
    logging.info(f"[algorithm-a] received audio: {msg}")

    # Dummy feature extraction
    features = {
        "audio_id": msg.get("audio_id"),
        "timestamp": time.time(),
        "features": {
            "volume": 0.73,
            "pitch": 120
        }
    }

    ch.basic_publish(
        exchange="",
        routing_key=OUTPUT_QUEUE,
        body=json.dumps(features)
    )

    logging.info(f"[algorithm-a] sent features: {features}")
    ch.basic_ack(method.delivery_tag)


def main():
    conn = connect()
    ch = conn.channel()

    ch.queue_declare(queue=INPUT_QUEUE, durable=True)
    ch.queue_declare(queue=OUTPUT_QUEUE, durable=True)

    ch.basic_qos(prefetch_count=1)
    ch.basic_consume(queue=INPUT_QUEUE, on_message_callback=process_message)

    logging.info("[algorithm-a] waiting for audio messages")
    ch.start_consuming()


if __name__ == "__main__":
    main()
