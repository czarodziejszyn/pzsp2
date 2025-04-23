import cv2
import mediapipe as mp
import csv

mp_pose = mp.solutions.pose
pose = mp_pose.Pose(static_image_mode=False, model_complexity=1)
mp_drawing = mp.solutions.drawing_utils

cap = cv2.VideoCapture('dance_video.mp4')

with open('dance_landmarks.csv', mode='w', newline='') as csv_file:
    csv_writer = csv.writer(csv_file)
    
    headers = ['frame']
    for i in range(33):
        headers += [f'x_{i}', f'y_{i}', f'z_{i}', f'visibility_{i}']
    csv_writer.writerow(headers)

    frame_num = 0

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = pose.process(frame_rgb)

        if results.pose_landmarks:
            row = [frame_num]
            for landmark in results.pose_landmarks.landmark:
                row.extend([landmark.x, landmark.y, landmark.z, landmark.visibility])
            csv_writer.writerow(row)

        frame_num += 1

cap.release()
