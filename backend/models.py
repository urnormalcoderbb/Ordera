from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey, DateTime, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
from .database import Base

class Restaurant(Base):
    __tablename__ = "restaurants"

    id = Column(Integer, primary_key=True, index=True)
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    city = Column(String, index=True, default="Unknown") # New City Column

    users = relationship("User", back_populates="restaurant")
    categories = relationship("Category", back_populates="restaurant")
    products = relationship("Product", back_populates="restaurant")
    orders = relationship("Order", back_populates="restaurant")


class Category(Base):
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    restaurant_id = Column(Integer, ForeignKey("restaurants.id"))
    
    restaurant = relationship("Restaurant", back_populates="categories")
    products = relationship("Product", back_populates="category")


from sqlalchemy import UniqueConstraint

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, index=True) # Removed unique=True
    hashed_password = Column(String)
    role = Column(String) # "admin", "kiosk", "kitchen"
    restaurant_id = Column(Integer, ForeignKey("restaurants.id"))
    
    restaurant = relationship("Restaurant", back_populates="users")

    __table_args__ = (UniqueConstraint('restaurant_id', 'username', name='uix_restaurant_username'),)

class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String)
    price = Column(Float)
    image_url = Column(String)
    category_id = Column(Integer, ForeignKey("categories.id"))
    is_available = Column(Boolean, default=True)
    modifiers = Column(JSON, default={})
    restaurant_id = Column(Integer, ForeignKey("restaurants.id"))

    restaurant = relationship("Restaurant", back_populates="products")
    category = relationship("Category", back_populates="products")

class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    status = Column(String, default="pending") # pending, paid, preparing, ready, completed
    total_amount = Column(Float)
    payment_status = Column(String, default="unpaid")
    created_at = Column(DateTime, default=datetime.utcnow)
    restaurant_id = Column(Integer, ForeignKey("restaurants.id"))
    
    restaurant = relationship("Restaurant", back_populates="orders")
    items = relationship("OrderItem", back_populates="order")

class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"))
    product_id = Column(Integer, ForeignKey("products.id"))
    quantity = Column(Integer, default=1)
    selected_modifiers = Column(JSON, default={}) 
    
    order = relationship("Order", back_populates="items")
    product = relationship("Product")
