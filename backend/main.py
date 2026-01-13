from starlette.applications import Starlette
from starlette.routing import Route, WebSocketRoute, Mount
from starlette.middleware import Middleware
from starlette.middleware.cors import CORSMiddleware
from starlette.responses import JSONResponse
from starlette.staticfiles import StaticFiles
from . import models, auth, endpoints, ws_manager
from .database import engine, SessionLocal
import os

# Create Tables
models.Base.metadata.create_all(bind=engine)

# Ensure uploads directory exists
UPLOADS_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads")
os.makedirs(UPLOADS_DIR, exist_ok=True)

# Seed Admin - Removed to enforce Multi-Tenant Signup
# with endpoints.database.get_db_context() as db:
#     pass

async def homepage(request):
    return JSONResponse({"message": "Welcome to Ordera API (Starlette Edition)"})

async def websocket_endpoint(websocket):
    # expect /ws/kitchen?restaurant_id=X or ideally authenticated.
    # For prototype, we will pass it in query param
    restaurant_id = websocket.query_params.get("restaurant_id")
    if not restaurant_id:
        await websocket.close()
        return
        
    res_id = int(restaurant_id)
        
    await ws_manager.manager.connect(websocket, res_id)
    try:
        while True:
            await websocket.receive_text()
    except:
        ws_manager.manager.disconnect(websocket, res_id)

routes = [
    Route("/", homepage),
    Route("/signup", endpoints.signup, methods=["POST"]),
    Route("/token", endpoints.login, methods=["POST"]),
    Route("/verify-password", endpoints.verify_password, methods=["POST"]),
    Route("/categories/", endpoints.list_categories, methods=["GET"]),
    Route("/categories/", endpoints.create_category, methods=["POST"]),
    Route("/categories/{category_id:int}", endpoints.update_category, methods=["PUT"]),
    Route("/categories/{category_id:int}", endpoints.delete_category, methods=["DELETE"]),
    Route("/products/", endpoints.list_products, methods=["GET"]),
    Route("/products/", endpoints.create_product, methods=["POST"]),
    Route("/products/{product_id:int}", endpoints.update_product, methods=["PUT"]),
    Route("/products/{product_id:int}", endpoints.delete_product, methods=["DELETE"]),
    Route("/upload", endpoints.upload_image, methods=["POST"]),
    Route("/orders/", endpoints.list_orders, methods=["GET"]),
    Route("/orders/", endpoints.create_order, methods=["POST"]),
    Route("/orders/{order_id:int}/status", endpoints.update_order_status, methods=["PUT"]),
    Mount("/uploads", StaticFiles(directory=UPLOADS_DIR), name="uploads"),
    WebSocketRoute("/ws/kitchen", websocket_endpoint),
]


# Validates that requests are actually reaching the server
from starlette.middleware.base import BaseHTTPMiddleware
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("ordera")

class LoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        logger.info(f"INCOMING REQUEST: {request.method} {request.url}")
        response = await call_next(request)
        logger.info(f"RESPONSE STATUS: {response.status_code}")
        return response

middleware = [
    Middleware(CORSMiddleware, allow_origins=["*"], allow_headers=["*"], allow_methods=["*"]),
    Middleware(LoggingMiddleware)
]

app = Starlette(debug=True, routes=routes, middleware=middleware)
