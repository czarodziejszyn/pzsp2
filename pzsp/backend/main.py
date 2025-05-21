# Odpalanie:
# uvicorn main:app --host 0.0.0.0 --port 8000
from fastapi import FastAPI
import socketio
import base64
from io import BytesIO
from PIL import Image

sio = socketio.AsyncServer(
    async_mode="asgi",
    cors_allowed_origins="*"
)

fastapi_app = FastAPI()

app = socketio.ASGIApp(sio, other_asgi_app=fastapi_app)


@sio.event
async def connect(sid, environ):
    print(f"[CONNECT] {sid}")

@sio.event
async def disconnect(sid):
    print(f"[DISCONNECT] {sid}")

@sio.event
async def frame(sid, data):
    try:
        import json
        data = json.loads(data)
        timestamp = data['timestamp_ms']
        image_data = data['image']
        img = Image.open(BytesIO(base64.b64decode(image_data)))
        print(f"Got frame at {timestamp} ms | size: {img.size}")
    except Exception as e:
        print(f"Error processing frame: {e}")

@sio.event
async def status(sid, data):
    import json
    try:
        data = json.loads(data)
        print(f"Status: {data['status']}")
        if data['status'] == 'start':
            print('Starting at second:', data['time'])
    except Exception as e:
        print(f"Error processing status: {e}")
