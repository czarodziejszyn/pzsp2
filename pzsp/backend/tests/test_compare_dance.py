from python.compare_dance import get_csv, load_pose_csv, process_image
import os
import numpy as np
from PIL import Image


# def test_get_csv(tmp_path):
#     url = ""
#     downloaded = get_csv(url)
#
#     assert os.path.exists(downloaded)
#     assert downloaded.endswith(".csv")


def test_load_pose_csv():
    path = "tests/test_data/test_landmarks.csv"
    poses = load_pose_csv(path)

    assert isinstance(poses, np.ndarray)
    assert poses.shape[1] == 14


def test_process_image_valid():
    film_id = "tests/test_data/test_landmarks"
    start_sec = 0
    offset_ms = 0

    img = Image.open("tests/test_data/test_image.jpg")

    result = process_image(film_id, start_sec, img, offset_ms)

    assert isinstance(result, float)
    assert 0.0 <= result <= 1.0
