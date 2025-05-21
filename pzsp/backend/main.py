from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from yolo_utils import process_frame
import base64

app = FastAPI()

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_json()

            if data.get("status") == "done":
                print(">>> KONIEC FILMIKU")
                break
            elif data.get("status") == "interrupted":
                print(">>> PRZERWANO FILMIK")
                break

            timestamp = data["timestamp"]
            image_b64 = data["image"]
            image_bytes = base64.b64decode(image_b64)

            results = await process_frame(image_bytes, timestamp)
            print(f"[{timestamp} ms] {results}")
    except WebSocketDisconnect:
        print("WebSocket: Client disconnected.")

