from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from .. import database, models, schemas, auth, websockets
import json

router = APIRouter(
    prefix="/orders",
    tags=["Orders"]
)

@router.post("/", response_model=schemas.Order)
async def create_order(order: schemas.OrderCreate, db: Session = Depends(database.get_db)):
    # Create Order
    db_order = models.Order(total_amount=order.total_amount, payment_status=order.payment_status, status="pending")
    db.add(db_order)
    db.commit()
    db.refresh(db_order)
    
    # Create Order Items
    for item in order.items:
        db_item = models.OrderItem(order_id=db_order.id, **item.dict())
        db.add(db_item)
    
    db.commit()
    db.refresh(db_order)
    
    # Broadcast to Kitchen
    await websockets.manager.broadcast(json.dumps({"event": "new_order", "order_id": db_order.id}))
    
    return db_order

@router.get("/", response_model=List[schemas.Order])
def read_orders(skip: int = 0, limit: int = 100, db: Session = Depends(database.get_db)):
    orders = db.query(models.Order).order_by(models.Order.created_at.desc()).offset(skip).limit(limit).all()
    return orders

@router.put("/{order_id}/status", response_model=schemas.Order)
async def update_order_status(order_id: int, status_update: str, db: Session = Depends(database.get_db), current_user: models.User = Depends(auth.get_current_user)):
    db_order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if not db_order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    db_order.status = status_update
    db.commit()
    db.refresh(db_order)
    
    # Broadcast status update
    await websockets.manager.broadcast(json.dumps({"event": "order_update", "order_id": order_id, "status": status_update}))
    
    return db_order
