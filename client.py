import socket
import json
from compare_dance import compare_points

scores = compare_points
json_scores = json.dumps(scores)

HOST = '127.0.0.1'
PORT = 65432

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    print("Connecting...")
    conn, addr = s.accept()
    with conn:
        print("Connected")
        data = json_scores.encode("utf-8")
        conn.sendall(len(data).to_bytes(4, byteorder="big"))
        conn.sendall(data)
