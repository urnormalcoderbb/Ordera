from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from backend.models import Base, Product, Order
from backend.database import SQLALCHEMY_DATABASE_URL

print(f"Connecting to {SQLALCHEMY_DATABASE_URL}")
try:
    engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
    Base.metadata.create_all(bind=engine)
    print("Tables created/verified.")
    
    SessionLocal = sessionmaker(bind=engine)
    db = SessionLocal()
    
    print("Querying products...")
    products = db.query(Product).all()
    print(f"Products count: {len(products)}")
    
    db.close()
    print("DB Check Success")
except Exception as e:
    print(f"DB Check Failed: {e}")
    import traceback
    traceback.print_exc()
