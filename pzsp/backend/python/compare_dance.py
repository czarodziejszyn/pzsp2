import cv2
import mediapipe as mp
import numpy as np
import csv
from .algorithm import pose_angle_score

import requests
import os


def get_csv(supabase_url):
    filename = os.path.basename(supabase_url)
    save_path = os.path.join("tmp", filename)

    os.makedirs("tmp", exist_ok=True)

    try:
        response = requests.get(supabase_url)
        response.raise_for_status()

        with open(save_path, "wb") as f:
            f.write(response.content)

    except requests.exceptions.RequestException as e:
        print(f"Download error: {e}")
    except IOError as e:
        print(f"saving error: {e}")

    return save_path


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
        _ = next(reader)

        num_points = len(SELECTED_INDICES)

        for row in reader:
            frame_vector = []
            for i in range(num_points):
                x = float(row[1 + i * 2])
                y = float(row[2 + i * 2])
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
        print("cos z len")
        return 0.0

    video_pose = data["motion"][frame_number]
    video_selected = np.array([video_pose[i]
                              for i in range(len(SELECTED_INDICES))])

    print(type(image_data))
    results = pose.process(image_data)
    print(results)

    if not results.pose_landmarks:
        print("cos z landmarks")
        return 0.0

    camera_pose = results.pose_landmarks.landmark
    camera_selected = np.array(
        [[camera_pose[i].x, camera_pose[i].y] for i in SELECTED_INDICES])

    return int(100*pose_angle_score(camera_selected, video_selected))
