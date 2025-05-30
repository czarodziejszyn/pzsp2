# Odpalanie:
# uvicorn main:app --host 0.0.0.0 --port 8000
from fastapi import FastAPI
import socketio
import base64
from io import BytesIO
from PIL import Image
from python.compare_dance import process_image, get_csv, motion_cache, load_pose_csv, DEFAULT_FRAME_RATE
from python.video_to_csv import extract_pose_landmarks
import os
import uuid
import numpy as np
import cv2


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
        "id": None,
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
        print(data)
        status = data.get('status')
        print(status)
        if status == 'start':
            title = data.get("title")
            print(title)
            film_id = data.get("id")
            print(film_id)
            start_sec = int(data.get("time", 0))
            print(start_sec)

            local_path = get_csv(title)
            motion = load_pose_csv(local_path)
            film_id = str(uuid.uuid4())

            motion_cache[film_id] = {
                "motion": motion,
                "fps": DEFAULT_FRAME_RATE
            }

            sessions[sid] = {
                "id": film_id,
                "start_sec": start_sec,
                "results": []
            }

        elif status == 'done':
            print(f"[] Sending results to {sid}")
            print(sessions[sid]["results"])
            await sio.emit("result", sessions[sid]["results"], to=sid)

            try:
                csv_path = sessions[sid].get("csv_path")
                if csv_path and os.path.exists(csv_path):
                    os.remove(csv_path)
                    print("CSV FILE DELETED")
            except Exception as cleanup_err:
                print(f"[ERROR] {cleanup_err}")

    except Exception as e:
        print(f"[ERROR][status] {e}")


@sio.event
async def frame(sid, data):
    try:
        data = json.loads(data)
        timestamp = int(data['timestamp_ms'])
        image_data = base64.b64decode(data['image'])

        img = Image.open(BytesIO(image_data)).convert("RGB")
        img_np = np.array(img)
        img_cv2 = cv2.cvtColor(img_np, cv2.COLOR_RGB2BGR)

        print(f"Obraz: shape={img_cv2.shape}, dtype={img_cv2.dtype}")

        session = sessions.get(sid)
        if not session or session["id"] is None:
            print(f"[WARN] Frame received before session start from {sid}")
            return

        result = process_image(
            session["id"],
            session["start_sec"],
            img_cv2,
            timestamp
        )
        session["results"].append(result)
        print(f"[FRAME] Time: {timestamp}ms | Result: {result}")

    except Exception as e:
        print(f"[ERROR][frame] {e}")


@sio.event
async def new_video_uploaded(sid, data):
    try:
        data = json.loads(data)
        video_name = data.get("filename")

        print(f"[NEW VIDEO] Otrzymano plik: {video_name}")

        # trzeba pobrać mp4, wtedy wytworzyć csv i to csv zapisać w supabase
        video_path, output_csv = "", ""
        extract_pose_landmarks(video_path, output_csv)

    except Exception as e:
        print(f"[ERROR][new_video_uploaded] {e}")
