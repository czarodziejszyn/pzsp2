import cv2
import mediapipe as mp
import numpy as np
import csv
from .algorithm import pose_angle_score

SELECTED_INDICES = [7, 8, 11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28]
POSE_POINTS = 33
POSE_DIM = 2  # x, y
DEFAULT_FRAME_RATE = 30.0

motion_cache = {}

mp_pose = mp.solutions.pose
pose = mp_pose.Pose(static_image_mode=True)

def load_pose_csv(csv_path):
    pose_sequence = []
    with open(csv_path, newline='') as csvfile:
        reader = csv.reader(csvfile)
        headers = next(reader)
        for row in reader:
            frame_vector = []
            for i in range(POSE_POINTS):
                x = float(row[1 + i * 4])
                y = float(row[2 + i * 4])
                frame_vector.append((x, y))
            pose_sequence.append(frame_vector)
    return np.array(pose_sequence)

def process_image(film_id, start_sec, image_data, offset_ms):
    if film_id not in motion_cache:
        csv_path = f"{film_id}.csv"
        reference_motion = load_pose_csv(csv_path)
        motion_cache[film_id] = {
            "motion": reference_motion,
            "fps": DEFAULT_FRAME_RATE
        }

    data = motion_cache[film_id]
    frame_number = int((start_sec + offset_ms / 1000.0) * data["fps"])

    if frame_number >= len(data["motion"]):
        return 0.0

    video_pose = data["motion"][frame_number]
    video_selected = np.array([video_pose[i] for i in SELECTED_INDICES])

    image_rgb = cv2.cvtColor(image_data, cv2.COLOR_BGR2RGB)
    results = pose.process(image_rgb)

    if not results.pose_landmarks:
        return 0.0

    camera_pose = results.pose_landmarks.landmark
    camera_selected = np.array([[camera_pose[i].x, camera_pose[i].y] for i in SELECTED_INDICES])

    return pose_angle_score(camera_selected, video_selected)

