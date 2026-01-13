print("Importing backend.database...")
try:
    import backend.database
    print("Success")
except Exception as e:
    print(f"Failed: {e}")
