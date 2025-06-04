import unittest
import os
import csv
import sys
sys.path.append(os.path.abspath('../python'))
from video_to_csv import extract_pose_landmarks


class TestPoseLandmarkExtraction(unittest.TestCase):
    def setUp(self):
        self.test_video = 'ballet.mp4'
        self.output_csv = 'ballet.csv'

    def tearDown(self):
        if os.path.exists(self.output_csv):
            os.remove(self.output_csv)

    def test_csv_file_created(self):
        extract_pose_landmarks(self.test_video, self.output_csv)
        self.assertTrue(os.path.exists(self.output_csv))

    def test_csv_has_correct_headers(self):
        extract_pose_landmarks(self.test_video, self.output_csv)
        with open(self.output_csv, newline='') as csvfile:
            reader = csv.reader(csvfile)
            headers = next(reader)
            expected_indices = [7, 8, 11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28]
            expected_headers = ['frame']
            for i in expected_indices:
                expected_headers += [f'x_{i}', f'y_{i}']
            self.assertEqual(headers, expected_headers)

    def test_csv_contains_data(self):
        extract_pose_landmarks(self.test_video, self.output_csv)
        with open(self.output_csv, newline='') as csvfile:
            reader = csv.reader(csvfile)
            next(reader)  # skip headers
            rows = list(reader)
            self.assertGreater(len(rows), 0)


if __name__ == '__main__':
    unittest.main()
