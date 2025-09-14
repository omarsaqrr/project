import json
import os
import redis.asyncio as redis

REDIS_URL = os.getenv("REDIS_URL", "redis://redis:6379/0")
r = redis.from_url(REDIS_URL, decode_responses=True)

async def cache_get(key: str):
    val = await r.get(key)
    return json.loads(val) if val else None

async def cache_set(key: str, value, expire: int = 60):
    await r.set(key, json.dumps(value), ex=expire)
