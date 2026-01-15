import hmac
import hashlib
import base64
import json
from datetime import datetime, timedelta
from typing import Optional
from starlette.requests import Request

# Configuration
SECRET_KEY = "your_secret_key_keep_it_safe"
ALGORITHM = "HS256"

# --- Pure Python Crypto Primitives ---

def get_password_hash(password: str) -> str:
    # Fixed salt for prototype stability
    salt = "fixed_salt_for_proto" 
    return hashlib.sha256((password + salt).encode()).hexdigest()

def verify_password(plain_password: str, hashed_password: str) -> bool:
    salt = "fixed_salt_for_proto"
    return hashlib.sha256((plain_password + salt).encode()).hexdigest() == hashed_password

# --- Pure Python JWT Implementation ---

def base64url_encode(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b'=').decode('utf-8')

def base64url_decode(data: str) -> bytes:
    padding = '=' * (4 - (len(data) % 4))
    return base64.urlsafe_b64decode(data + padding)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(hours=24)
    # Convert datetime to timestamp
    to_encode.update({"exp": int(expire.timestamp())})
    
    # Header
    header = {"typ": "JWT", "alg": ALGORITHM}
    header_json = json.dumps(header).encode('utf-8')
    header_b64 = base64url_encode(header_json)
    
    # Payload
    payload_json = json.dumps(to_encode).encode('utf-8')
    payload_b64 = base64url_encode(payload_json)
    
    # Signature
    msg = f"{header_b64}.{payload_b64}".encode('utf-8')
    signature = hmac.new(SECRET_KEY.encode('utf-8'), msg, hashlib.sha256).digest()
    signature_b64 = base64url_encode(signature)
    
    return f"{header_b64}.{payload_b64}.{signature_b64}"

def decode_token(token: str) -> Optional[dict]:
    try:
        parts = token.split('.')
        if len(parts) != 3:
            return None
            
        header_b64, payload_b64, signature_b64 = parts
        
        # Verify Signature
        msg = f"{header_b64}.{payload_b64}".encode('utf-8')
        expected_sig = hmac.new(SECRET_KEY.encode('utf-8'), msg, hashlib.sha256).digest()
        expected_sig_b64 = base64url_encode(expected_sig)
        
        if not hmac.compare_digest(signature_b64, expected_sig_b64):
            return None
            
        # Decode Payload
        payload_json = base64url_decode(payload_b64).decode('utf-8')
        payload = json.loads(payload_json)
        
        # Check Expiry
        exp = payload.get("exp")
        if exp and datetime.utcnow().timestamp() > exp:
            return None
            
        return payload
    except Exception:
        return None

# --- Utils ---

def get_current_user_token(request: Request) -> Optional[str]:
    auth_header = request.headers.get("Authorization")
    if not auth_header:
        # Check query param (for WebSocket)
        return request.query_params.get("token")
    scheme, _, param = auth_header.partition(" ")
    if scheme.lower() != "bearer":
        return None
    return param

# We don't really need a full User object loader in auth.py anymore, 
# endpoints can do it with the decoded token data.
# But for compatibility with existing import in endpoints:
import database, models

# Mock jwt class for endpoints usage if they call jwt.decode directly (which endpoints.py does)
class MockJWT:
    def decode(self, token, key, algorithms):
        # We ignore key/algos as we hardcoded them in decode_token above
        return decode_token(token)

jwt = MockJWT()
