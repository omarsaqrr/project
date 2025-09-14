from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.db import get_session, init_db
from app.crud import create_item, get_item_by_id
from app.cache import cache_get, cache_set

app = FastAPI()

@app.on_event("startup")
async def startup():
    await init_db()

@app.post("/items/")
async def create(item: dict, db: AsyncSession = Depends(get_session)):
    created = await create_item(db, item)
    return created

@app.get("/items/{item_id}")
async def read(item_id: int, db: AsyncSession = Depends(get_session)):
    # try cache
    cached = await cache_get(f"item:{item_id}")
    if cached:
        return {"source": "redis", "data": cached}

    item = await get_item_by_id(db, item_id)
    if not item:
        raise HTTPException(404, "Item not found")

    await cache_set(f"item:{item_id}", item, expire=60)
    return {"source": "postgres", "data": item}
