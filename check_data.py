from backend.database import SessionLocal
from backend.models import Restaurant, User, Product

db = SessionLocal()
r_count = db.query(Restaurant).count()
u_count = db.query(User).count()
p_count = db.query(Product).count()

print(f"Restaurants: {r_count}")
print(f"Users: {u_count}")
print(f"Products: {p_count}")

if r_count > 0:
    r = db.query(Restaurant).first()
    print(f"Restaurant 1: {r.name} (ID: {r.id})")
    users = db.query(User).filter(User.restaurant_id == r.id).all()
    print(f"Users for R1: {[u.username for u in users]}")

db.close()
