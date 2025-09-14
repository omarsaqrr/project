# ---------- BUILDER STAGE ----------
FROM python:3.11-slim AS builder

# Prevents Python from writing .pyc files and buffers
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# System dependencies for building wheels
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev gcc curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies into /install (isolated dir)
COPY app/requirements.txt .
RUN pip install --prefix=/install --no-cache-dir -r requirements.txt \
 && pip uninstall -y aioredis || true


# ---------- FINAL STAGE ----------
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Copy installed dependencies from builder
COPY --from=builder /install /usr/local

# Copy app source
COPY app /app/app

EXPOSE 8000

# Default run command
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers"]
