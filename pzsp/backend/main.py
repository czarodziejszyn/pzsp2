# Odpalanie:
# uvicorn main:app --host 0.0.0.0 --port 8000
from fastapi import FastAPI
import socketio
import base64
from io import BytesIO
from PIL import Image
from python.compare_dance import process_image

import json

sio = socketio.AsyncServer(
    async_mode="asgi",
    cors_allowed_origins="*"
)
fastapi_app = FastAPI()
app = socketio.ASGIApp(sio, other_asgi_app=fastapi_app)

# Global state
sessions = {}


@sio.event
async def connect(sid, environ):
    print(f"[CONNECT] {sid}")
    sessions[sid] = {
        "film_id": None,
        "start_sec": 0,
        "results": []
    }

@sio.event
async def disconnect(sid):
    print(f"[DISCONNECT] {sid}")
    sessions.pop(sid, None)

@sio.event
async def status(sid, data):
    try:
        data = json.loads(data)
        status = data.get('status')
        if status == 'start':
            sessions[sid]["film_id"] = int(data['film_id'])
            sessions[sid]["start_sec"] = int(data['time'])
            sessions[sid]["results"] = []
            print(f"[START] Film ID: {sessions[sid]['film_id']}, Start at: {sessions[sid]['start_sec']}s")

        elif status == 'done':
            print(f"[] Sending results to {sid}")
            await sio.emit("result", sessions[sid]["results"], to=sid)

    except Exception as e:
        print(f"[ERROR][status] {e}")

@sio.event
async def frame(sid, data):
    try:
        data = json.loads(data)
        timestamp = int(data['timestamp_ms'])
        image_data = base64.b64decode(data['image'])
        img = Image.open(BytesIO(image_data))

        session = sessions.get(sid)
        if not session or session["film_id"] is None:
            print(f"[WARN] Frame received before session start from {sid}")
            return

        # Process image
        result = process_image(
            session["film_id"],
            session["start_sec"],
            image_data,
            timestamp
        )
        session["results"].append(result)
        print(f"[FRAME] Time: {timestamp}ms | Result: {result}")

    except Exception as e:
        print(f"[ERROR][frame] {e}")

