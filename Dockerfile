# syntax=docker/dockerfile:1
FROM python:3.12-slim

WORKDIR /app

# pandas / scikit-learn need a compiler-free install only; no system deps required.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV SECRET_KEY=change-me-in-production
# Render's default port. The app reads $PORT at runtime (see app.py).
EXPOSE 10000

# Production WSGI server, bound to 0.0.0.0:$PORT (Render injects $PORT).
# Shell form is required so $PORT is expanded at container start.
CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:${PORT:-10000} app:app"]
