import socket
import struct
from io import BytesIO
from PIL import Image
from compare_dance import process_image

HOST = '0.0.0.0'
PORT = 9000

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server:
    server.bind((HOST, PORT))
    server.listen(1)
    print(f"{HOST}:{PORT}")

    conn, addt = server.accept()
    with conn:
        print("Connected")
        while True:
            header = conn.recv(12)
            if len(header) < 12:
                print("Disconnected")
                break

            img_len, timestamp_ms = struct.unpack('>Iq', header)

            image_data = 'b'
            while len(image_data) < img_len:
                packet = conn.recv(img_len - len(image_data))
                if not packet:
                    break
                image_data += packet

            if len(image_data) != img_len:
                ("Not full image")
                break

           process_image(image_data, timestamp_ms) 
