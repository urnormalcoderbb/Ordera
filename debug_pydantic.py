from pydantic import BaseModel

try:
    class User(BaseModel):
        id: int
        name: str

    u = User(id=1, name="Test")
    print(f"Pydantic works: {u}")
except Exception as e:
    print(f"Pydantic failed: {e}")
