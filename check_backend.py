import sys
import os

# Add current directory to path
sys.path.append(os.getcwd())

try:
    print("Attempting to import backend.main...")
    import backend.main
    print("Successfully imported backend.main")
except Exception as e:
    print(f"Failed to import backend.main: {e}")
    import traceback
    traceback.print_exc()
