import requests
import sys

BASE_URL = "http://127.0.0.1:8000"

def test_signup_login():
    # 1. Signup
    print("1. Testing Signup...")
    signup_data = {
        "restaurant_name": "Test Bistro",
        "username": "owner",
        "password": "password123"
    }
    try:
        r = requests.post(f"{BASE_URL}/signup", json=signup_data)
        print(f"Signup Status: {r.status_code}")
        print(f"Signup Response: {r.text}")
        if r.status_code != 200:
            print("Signup Failed")
            return
    except Exception as e:
        print(f"Signup Exception: {e}")
        return

    # 2. Login
    print("\n2. Testing Login...")
    login_data = {
        "username": "owner",
        "password": "password123"
    }
    try:
        r = requests.post(f"{BASE_URL}/token", data=login_data)
        print(f"Login Status: {r.status_code}")
        print(f"Login Response: {r.text}")
        if r.status_code == 200:
            print("Login Successful")
        else:
            print("Login Failed")
    except Exception as e:
         print(f"Login Exception: {e}")

if __name__ == "__main__":
    test_signup_login()
