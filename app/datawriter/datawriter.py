import json
import logging
import os
import pika
import psycopg2
import threading

logging.basicConfig(level=logging.INFO)

RABBIT_HOST = os.getenv("RABBIT_HOST")
RABBIT_USER = os.getenv("RABBIT_USER")
RABBIT_PASS = os.getenv("RABBIT_PASS")

DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_NAME = os.getenv("DB_NAME")

FEATURE_QUEUE = "features"


def db_insert(feature):
    conn = psycopg2.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        dbname=DB_NAME
    )
    cur = conn.cursor()

    cur.execute(
        """
        INSERT INTO features (audio_id, ts, data)
        VALUES (%s, to_timestamp(%s), %s)
        """,
        (
            feature["audio_id"],
            feature["timestamp"],
            json.dumps(feature["features"])
        )
    )

    conn.commit()
    cur.close()
    conn.close()


def process_message(ch, method, properties, body):
    feature = json.loads(body)
    logging.info(f"[datawriter] received feature: {feature}")

    # async DB write
    threading.Thread(target=db_insert, args=(feature,)).start()

    ch.basic_ack(method.delivery_tag)


def main():
    creds = pika.PlainCredentials(RABBIT_USER, RABBIT_PASS)
    params = pika.ConnectionParameters(RABBIT_HOST, credentials=creds)
    conn = pika.BlockingConnection(params)

    ch = conn.channel()
    ch.queue_declare(queue=FEATURE_QUEUE, durable=True)

    ch.basic_qos(prefetch_count=5)
    ch.basic_consume(queue=FEATURE_QUEUE, on_message_callback=process_message)

    logging.info("[datawriter] waiting for feature messages")
    ch.start_consuming()


if __name__ == "__main__":
    main()
