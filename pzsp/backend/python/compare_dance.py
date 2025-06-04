import mediapipe as mp
import numpy as np
import csv
from algorithm import pose_angle_score
from supabase import create_client

url = "https://meompxrfkofzbxjwjpvr.supabase.co"
anon_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1lb21weHJma29memJ4andqcHZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU0Njk4MzQsImV4cCI6MjA2MTA0NTgzNH0.GLRSPS_TZ66-W2mSLrnYZzf_belmq32CW157pvJXwLA"
save_dir = "tmp"

supabase = create_client(url, anon_key)


def get_csv(filename, supabase_client=supabase):
    bucket = "pose-points"
    save_path = f"{save_dir}/{filename}.csv"

    data_response = supabase_client.storage.from_(bucket).download(f"{filename}.csv")
    if data_response is None:
        print(f"Nie udało się pobrać pliku {filename}.csv z bucketu {bucket}")
        return None

    try:
        with open(save_path, "wb") as f:
            f.write(data_response)
        print(f"Pobrano i zapisano plik: {save_path}")
    except IOError as e:
        print(f"Błąd zapisu pliku: {e}")
        return None

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
