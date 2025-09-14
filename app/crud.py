from sqlalchemy import select
from app.models import Item

async def create_item(db, item_data):
    obj = Item(**item_data)
    db.add(obj)
    await db.commit()
    await db.refresh(obj)
    return obj.to_dict()

async def get_item_by_id(db, item_id: int):
    q = await db.execute(select(Item).where(Item.id == item_id))
    item = q.scalars().first()
    return item.to_dict() if item else None
