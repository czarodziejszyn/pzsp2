import cv2
import mediapipe as mp
import numpy as np
import csv
from fastdtw import fastdtw
from scipy.spatial.distance import euclidean
from collections import deque
import matplotlib.pyplot as plt

def compare_points(camera_points, video_points):
    return score

def process_image(film_id, start_sec, image_data, offset):
    pass

VIDEO_PATH = "dance_video.mp4"
CSV_PATH = "dance_landmarks.csv"
WINDOW_NAME = "Live Dance Comparison"
POSE_POINTS = 33
SLIDING_WINDOW = 30

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
                frame_vector.extend([x, y])
            pose_sequence.append(frame_vector)
    return np.array(pose_sequence)

reference_motion = load_pose_csv(CSV_PATH)

mp_pose = mp.solutions.pose
pose = mp_pose.Pose()
mp_drawing = mp.solutions.drawing_utils

cap_video = cv2.VideoCapture(VIDEO_PATH)
cap_cam = cv2.VideoCapture(0)

user_window = deque(maxlen=SLIDING_WINDOW)
ref_window = deque(maxlen=SLIDING_WINDOW)
similarity_history = []

frame_idx = 0
frame_rate = cap_video.get(cv2.CAP_PROP_FPS)

while cap_video.isOpened():
    ret_video, frame_video = cap_video.read()
    ret_cam, frame_cam = cap_cam.read()
    if not ret_video or not ret_cam:
        break

    cam_rgb = cv2.cvtColor(frame_cam, cv2.COLOR_BGR2RGB)
    results = pose.process(cam_rgb)
    cam_out = frame_cam.copy()

    if results.pose_landmarks:
        mp_drawing.draw_landmarks(cam_out, results.pose_landmarks, mp_pose.POSE_CONNECTIONS)
        user_vec = []
        for lm in results.pose_landmarks.landmark:
            user_vec.extend([lm.x, lm.y])
        user_window.append(user_vec)
    else:
        user_window.append([0.0] * 66)

    if frame_idx < len(reference_motion):
        ref_vec = reference_motion[frame_idx]
        ref_window.append(ref_vec)

    comment = ""
    if len(user_window) == SLIDING_WINDOW and len(ref_window) == SLIDING_WINDOW:
        u_seq = np.array(user_window)
        r_seq = np.array(ref_window)
        dist, _ = fastdtw(u_seq, r_seq, dist=euclidean)
        sim = max(0, 100 - dist / 10)
        similarity_history.append(sim)

        if sim > 85:
            comment = "Great!"
            color = (0, 255, 0)
        elif sim > 65:
            comment = "Okay"
            color = (0, 255, 255)
        else:
            comment = "Try again"
            color = (0, 0, 255)

        cv2.putText(cam_out, f"{comment} ({sim:.1f}%)", (30, 50), cv2.FONT_HERSHEY_SIMPLEX,
                    1.2, color, 3)
    else:
        similarity_history.append(0)

    height = 480
    frame_video = cv2.resize(frame_video, (int(height * 16 / 9), height))
    cam_out = cv2.resize(cam_out, (int(height * 16 / 9), height))
    combined = np.hstack((frame_video, cam_out))

    cv2.imshow(WINDOW_NAME, combined)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

    frame_idx += 1

cap_video.release()
cap_cam.release()
cv2.destroyAllWindows()

valid_scores = [s for s in similarity_history if s > 0]
final_score = np.mean(valid_scores) if valid_scores else 0

print(f"\nŚrednie dopasowanie: {final_score:.2f}%")

plt.figure(figsize=(10, 4))
plt.plot(similarity_history, label="Similarity (%)")
plt.axhline(final_score, color='r', linestyle='--', label=f"Avg: {final_score:.1f}%")
plt.title("Zgodność tańca w czasie")
plt.xlabel("Klatka")
plt.ylabel("Dopasowanie (%)")
plt.ylim(0, 100)
plt.legend()
plt.grid()
plt.tight_layout()
plt.show()
