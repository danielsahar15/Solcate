from fastapi import FastAPI, Query
import psycopg2
import os
import json

app = FastAPI()

DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_NAME = os.getenv("DB_NAME")


def get_db():
    return psycopg2.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        dbname=DB_NAME
    )


@app.get("/features")
def get_features(
    start_ts: float = Query(...),
    end_ts: float = Query(...)
):
    conn = get_db()
    cur = conn.cursor()

    cur.execute(
        """
        SELECT audio_id, ts, data
        FROM features
        WHERE ts BETWEEN to_timestamp(%s) AND to_timestamp(%s)
        ORDER BY ts
        """,
        (start_ts, end_ts)
    )

    rows = cur.fetchall()
    cur.close()
    conn.close()

    return [
        {
            "audio_id": r[0],
            "timestamp": r[1].timestamp(),
            "features": r[2]
        }
        for r in rows
    ]

