# mediapipe wymaga pythona w niższej wersji np 3.10.12
import cv2
import sys
import mediapipe as mp

mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils
pose = mp_pose.Pose()

s = 0
if len(sys.argv) > 1:
    s = sys.argv[1]

source = cv2.VideoCapture(s)

win_name = 'Camera Preview'
cv2.namedWindow(win_name, cv2.WINDOW_NORMAL)

while cv2.waitKey(1) != 27: # escape
    has_frame, frame = source.read()
    if not has_frame:
        break
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    result = pose.process(rgb_frame)
    if result.pose_landmarks:
        mp_drawing.draw_landmarks(frame, result.pose_landmarks, mp_pose.POSE_CONNECTIONS)
    cv2.imshow(win_name, cv2.flip(frame, 1))

source.release()
cv2.destroyWindow(win_name)
