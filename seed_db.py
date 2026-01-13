from backend.database import SessionLocal
from backend.models import Product

def seed_menu():
    db = SessionLocal()
    if db.query(Product).count() > 0:
        print("Menu already populated.")
        return

    products = [
        Product(
            name="Classic Burger",
            description="Juicy beef patty with lettuce and tomato",
            price=8.99,
            category="Burgers",
            image_url="https://via.placeholder.com/150",
            modifiers={"size": ["Single", "Double"], "toppings": ["Cheese", "Bacon"]}
        ),
        Product(
            name="Cheese Fries",
            description="Crispy fries topped with melted cheddar",
            price=4.99,
            category="Sides",
            image_url="https://via.placeholder.com/150",
            modifiers={"size": ["Small", "Large"]}
        ),
        Product(
            name="Vanilla Shake",
            description="Creamy vanilla milkshake",
            price=5.99,
            category="Drinks",
            image_url="https://via.placeholder.com/150",
            modifiers={}
        )
    ]
    
    for p in products:
        db.add(p)
    
    db.commit()
    print("Seeded 3 products.")
    db.close()

if __name__ == "__main__":
    seed_menu()
