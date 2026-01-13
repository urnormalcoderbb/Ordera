from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime

# Token Schemas
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: str | None = None
    role: str | None = None

# User Schemas
class UserBase(BaseModel):
    username: str
    role: str # admin, owner (who selects mode)

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    
    class Config:
        orm_mode = True

# Product Schemas
class ProductBase(BaseModel):
    name: str
    description: str | None = None
    price: float
    image_url: str | None = None
    category: str
    is_available: bool = True
    modifiers: Dict[str, Any] = {} # e.g. {"size": ["S", "M", "L"]}

class ProductCreate(ProductBase):
    pass

class Product(ProductBase):
    id: int

    class Config:
        orm_mode = True

# Order Schemas
class OrderItemBase(BaseModel):
    product_id: int
    quantity: int
    selected_modifiers: Dict[str, Any] = {}

class OrderItemCreate(OrderItemBase):
    pass

class OrderItem(OrderItemBase):
    id: int
    order_id: int
    # including product details for ease of display would be good, but keeping schema simple for now
    
    class Config:
        orm_mode = True

class OrderBase(BaseModel):
    total_amount: float
    payment_status: str = "unpaid"

class OrderCreate(OrderBase):
    items: List[OrderItemCreate]

class Order(OrderBase):
    id: int
    status: str
    created_at: datetime
    items: List[OrderItem]

    class Config:
        from_attributes = True
