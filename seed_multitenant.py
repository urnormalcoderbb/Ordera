from backend.database import SessionLocal
from backend.models import Product, Restaurant, User
from backend.auth import get_password_hash

def seed_multitenant():
    db = SessionLocal()
    
    # Check if restaurant exists
    if db.query(Restaurant).count() > 0:
        print("Data already exists.")
        return

    # 1. Create Restaurant
    restaurant = Restaurant(name="Ordera Grill")
    db.add(restaurant)
    db.commit()
    db.refresh(restaurant)
    print(f"Created Restaurant: {restaurant.name} (ID: {restaurant.id})")

    # 2. Create Admin
    admin = User(
        username="admin",
        hashed_password=get_password_hash("admin123"),
        role="admin",
        restaurant_id=restaurant.id
    )
    db.add(admin)
    db.commit()
    print("Created Admin: admin / admin123")

    # 3. Create Products
    products = [
        Product(
            name="Double Cheeseburger",
            description="Two patties, extra cheese",
            price=12.99,
            category="Burgers",
            restaurant_id=restaurant.id,
            modifiers={"size": ["Single", "Double"]}
        ),
        Product(
            name="Large Fries",
            description="Crispy golden fries",
            price=5.99,
            category="Sides",
            restaurant_id=restaurant.id,
            modifiers={}
        ),
        Product(
            name="Chocolate Shake",
            description="Rich chocolate milkshake",
            price=6.99,
            category="Drinks",
            restaurant_id=restaurant.id,
            modifiers={}
        )
    ]
    
    for p in products:
        db.add(p)
    
    db.commit()
    print("Seeded 3 products for Ordera Grill.")
    db.close()

if __name__ == "__main__":
    seed_multitenant()
