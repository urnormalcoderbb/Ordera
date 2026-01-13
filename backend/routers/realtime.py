from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from .. import websockets

router = APIRouter(
    tags=["Realtime"]
)

@router.websocket("/ws/kitchen")
async def websocket_endpoint(websocket: WebSocket):
    await websockets.manager.connect(websocket)
    try:
        while True:
            await websocket.receive_text()
            # We can handle incoming kitchen messages here if needed (e.g. ping)
    except WebSocketDisconnect:
        websockets.manager.disconnect(websocket)
