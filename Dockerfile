FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# system deps (for asyncpg/build)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev gcc curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
 && pip uninstall -y aioredis || true

# Copy source code
COPY app /app/app

EXPOSE 8000

# Run FastAPI
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers"]
