import sys
print(f"Python: {sys.version}")

print("1. Importing starlette...")
try:
    import starlette
    print("   Starlette imported")
except ImportError:
    print("   Starlette NOT installed")
except Exception as e:
    print(f"   Failed: {e}")

print("2. Importing sqlalchemy...")
try:
    import sqlalchemy
    print(f"   SQLAlchemy: {sqlalchemy.__version__}")
except Exception as e:
    print(f"   Failed: {e}")
