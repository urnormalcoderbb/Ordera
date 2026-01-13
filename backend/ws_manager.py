from starlette.websockets import WebSocket
import collections

class ConnectionManager:
    def __init__(self):
        # Dictionary of List of WebSockets, keyed by restaurant_id
        self.active_connections: dict[int, list[WebSocket]] = collections.defaultdict(list)

    async def connect(self, websocket: WebSocket, restaurant_id: int):
        await websocket.accept()
        self.active_connections[restaurant_id].append(websocket)

    def disconnect(self, websocket: WebSocket, restaurant_id: int):
        if restaurant_id in self.active_connections:
            if websocket in self.active_connections[restaurant_id]:
                self.active_connections[restaurant_id].remove(websocket)

    async def broadcast(self, message: str, restaurant_id: int):
        if restaurant_id in self.active_connections:
             for connection in self.active_connections[restaurant_id]:
                 try:
                     await connection.send_text(message)
                 except:
                     pass # cleanup on disconnect usually

manager = ConnectionManager()
