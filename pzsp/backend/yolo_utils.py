from ultralytics import YOLO
import numpy as np
import cv2
from PIL import Image
import io

model = YOLO("yolov8n.pt")

async def process_frame(image_bytes, timestamp_ms):
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    frame = np.array(image)
    results = model(frame)

    detections = []
    for r in results:
        for box in r.boxes:
            cls = int(box.cls[0])
            conf = float(box.conf[0])
            detections.append({"class": cls, "conf": conf})

    return {"timestamp": timestamp_ms, "detections": detections}
