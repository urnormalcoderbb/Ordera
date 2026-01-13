import sys
print(f"Python: {sys.version}")

print("1. Importing pydantic...")
try:
    import pydantic
    print(f"   Pydantic: {pydantic.VERSION}")
except Exception as e:
    print(f"   Failed: {e}")

print("2. Importing fastapi...")
try:
    import fastapi
    print("   FastAPI imported")
except Exception as e:
    print(f"   Failed: {e}")

print("3. Importing sqlalchemy...")
try:
    import sqlalchemy
    print(f"   SQLAlchemy: {sqlalchemy.__version__}")
except Exception as e:
    print(f"   Failed: {e}")

print("4. Importing bcrypt...")
try:
    import bcrypt
    print("   bcrypt imported")
except Exception as e:
    print(f"   Failed: {e}")

print("5. Importing passlib...")
try:
    import passlib
    print("   passlib imported")
except Exception as e:
    print(f"   Failed: {e}")

print("6. Importing websockets...")
try:
    import websockets
    print("   websockets imported")
except Exception as e:
    print(f"   Failed: {e}")
