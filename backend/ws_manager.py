import os
import json
import asyncio
from starlette.websockets import WebSocket, WebSocketState
import collections
from broadcaster import Broadcast

# Get Redis URL from environment
REDIS_URL = os.getenv("REDIS_URL", "memory://")
broadcast = Broadcast(REDIS_URL)

class ConnectionManager:
    def __init__(self):
        # We don't necessarily need to track active_connections if 
        # broadcaster handles the delivery, but it's good for debugging/stats.
        self.active_connections: dict[int, list[WebSocket]] = collections.defaultdict(list)

    async def connect(self, websocket: WebSocket, restaurant_id: int):
        await websocket.accept()
        self.active_connections[restaurant_id].append(websocket)
        print(f"WS: Connected restaurant {restaurant_id}. Total connections for this ID: {len(self.active_connections[restaurant_id])}")

    def disconnect(self, websocket: WebSocket, restaurant_id: int):
        if restaurant_id in self.active_connections:
            if websocket in self.active_connections[restaurant_id]:
                self.active_connections[restaurant_id].remove(websocket)
                print(f"WS: Disconnected restaurant {restaurant_id}. Remaining: {len(self.active_connections[restaurant_id])}")

    async def broadcast_to_restaurant(self, message: str, restaurant_id: int):
        """Publishes the message to Redis channel for this restaurant"""
        print(f"BROADCAST: Sending to restaurant_{restaurant_id}: {message}")
        await broadcast.publish(channel=f"restaurant_{restaurant_id}", message=message)

manager = ConnectionManager()
