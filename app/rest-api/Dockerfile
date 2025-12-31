FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir flask psycopg2-binary

COPY rest_api.py .

EXPOSE 8080

CMD ["python", "-u", "rest_api.py"]
