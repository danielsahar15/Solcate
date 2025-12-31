FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir pika psycopg2-binary

COPY datawriter.py .

CMD ["python", "-u", "datawriter.py"]

