from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from ultralytics import YOLO
import numpy as np
import cv2
from PIL import Image
import io

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

model = YOLO("yolov8n-pose.pt")

@app.post("/analyze-frame")
async def analyze_frame(image: UploadFile = File(...)):
    contents = await image.read()

    image_pil = Image.open(io.BytesIO(contents)).convert("RGB")
    frame = np.array(image_pil)

    results = model(frame)

    keypoints = []
    for person in results[0].keypoints.xy:
        keypoints.append(person.cpu().numpy().tolist())

    return {"keypoints": keypoints}

