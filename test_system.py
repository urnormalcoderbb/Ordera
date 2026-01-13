import sys
print("Starting script...", flush=True)
try:
    import requests
    print("Requests imported", flush=True)
    from backend.database import SessionLocal
    print("SessionLocal imported", flush=True)
    from backend.models import Product, Order
    print("Models imported", flush=True)
    import websockets
    print("Websockets imported", flush=True)
    import asyncio
    import json
except Exception as e:
    print(f"Import failed: {e}", flush=True)
    sys.exit(1)

def seed_product():
    print("Seeding...", flush=True)
    try:
        db = SessionLocal()
        if db.query(Product).count() == 0:
            p = Product(
                name="Test Burger",
                description="Tasty",
                price=9.99,
                category="Burgers",
                is_available=True,
                modifiers={"size": ["S", "M"]}
            )
            db.add(p)
            db.commit()
            print("Seeded Product.", flush=True)
        else:
            print("Products already exist.", flush=True)
        db.close()
    except Exception as e:
        print(f"Seeding failed: {e}", flush=True)

def test_api():
    print("Testing API...", flush=True)
    try:
        r = requests.get("http://127.0.0.1:8000/products/")
        print(f"GET /products/: Status {r.status_code}", flush=True)
        print(f"Body: {r.text}", flush=True)
    except Exception as e:
        print(f"API Test Failed: {e}", flush=True)

async def test_ws():
    print("Testing WS...", flush=True)
    uri = "ws://127.0.0.1:8000/ws/kitchen"
    try:
        async with websockets.connect(uri) as websocket:
            print("WebSocket Connected!", flush=True)
    except Exception as e:
        print(f"WebSocket Test Failed: {e}", flush=True)

if __name__ == "__main__":
    seed_product()
    test_api()
    asyncio.run(test_ws())
