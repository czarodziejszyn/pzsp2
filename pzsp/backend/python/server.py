import socket
import struct
from io import BytesIO
from PIL import Image
from compare_dance import process_image

results = []

def send_result_array(conn, result_list):
    array_len = len(result_list)
    header = struct.pack(">I", array_len)
    body = b''.join(struct.pack(">i", val) for val in result_list)
    conn.sendall(header + body)
    print(f"[Wysłano] {array_len} wyników")

def start_server():
    HOST = '0.0.0.0'
    PORT = 9000

    global results
    results = []

    film_id, start_sec = 0, 0

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server:
        server.bind((HOST, PORT))
        server.listen(1)
        print(f"Serwer listening on {HOST}:{PORT}")

        conn, addr = server.accept()
        with conn:
            print(f"Connected")

            while True:
                msg_type_raw = conn.recv(1)
                if not msg_type_raw:
                    break

                msg_type = msg_type_raw[0]

                # wybor filmu
                if msg_type == 1:
                    header = conn.recv(12)
                    film_id, start_sec = struct.unpack(">Iq", header)
                    print(f"Film ID: {film_id}, Start: {start_sec}s")


                # JPEG + milisekunda
                elif msg_type == 2:
                    header = conn.recv(12)
                    img_len, offset = struct.unpack(">Iq", header)
                    image_data = b''
                    while len(image_data) < img_len:
                        chunk = conn.recv(img_len - len(image_data))
                        if not chunk:
                            break
                        image_data += chunk

                    result = process_image(film_id, start_sec, image_data, offset)
                    results.append(result)

                # koniec
                elif msg_type == 3:
                    print("Sending results...")
                    send_result_array(conn, results)
                    break

                else:
                    print(f"[Błąd] Nieznany typ wiadomości: {msg_type}")
                    break

