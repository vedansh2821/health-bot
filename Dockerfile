# syntax=docker/dockerfile:1
FROM python:3.12-slim

WORKDIR /app

# pandas / scikit-learn need a compiler-free install only; no system deps required.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV SECRET_KEY=change-me-in-production
EXPOSE 3000

CMD ["python", "app.py"]
