import cv2
import mediapipe as mp
import csv

def extract_pose_landmarks(video_path, output_csv='dance_landmarks.csv'):
    mp_pose = mp.solutions.pose
    pose = mp_pose.Pose(static_image_mode=False, model_complexity=1)
    
    selected_indices = [7, 8, 11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28]

    cap = cv2.VideoCapture(video_path)

    with open(output_csv, mode='w', newline='') as csv_file:
        csv_writer = csv.writer(csv_file)

        headers = ['frame']
        for i in selected_indices:
            headers += [f'x_{i}', f'y_{i}']
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
                for i in selected_indices:
                    landmark = results.pose_landmarks.landmark[i]
                    row.extend([landmark.x, landmark.y])
                csv_writer.writerow(row)

            frame_num += 1

    cap.release()

