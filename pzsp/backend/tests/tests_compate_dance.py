import unittest
from unittest.mock import patch, MagicMock, mock_open
import numpy as np
import io
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'python')))
from compare_dance import get_csv, load_pose_csv, process_image, SELECTED_INDICES

class TestPoseFunctions(unittest.TestCase):

    @patch("builtins.open", new_callable=mock_open, read_data="frame,x_7,y_7,x_8,y_8,x_11,y_11,x_12,y_12,x_13,y_13,x_14,y_14,x_15,y_15,x_16,y_16,x_23,y_23,x_24,y_24,x_25,y_25,x_26,y_26,x_27,y_27,x_28,y_28\n0,0.39822685718536377,0.3113730251789093,0.35590219497680664,0.31084540486335754,0.43900853395462036,0.3529272675514221,0.3272285461425781,0.3474627137184143,0.5426042675971985,0.3734949827194214,0.24562078714370728,0.3537190556526184,0.6415093541145325,0.38827353715896606,0.17253105342388153,0.3486538529396057,0.4237625002861023,0.4613242745399475,0.3610650300979614,0.4679647982120514,0.49949517846107483,0.5411436557769775,0.3855542540550232,0.5446063280105591,0.5813848376274109,0.621295690536499,0.4002991020679474,0.6240435838699341\n")
    def test_load_pose_csv(self, mock_file):
        pose_data = load_pose_csv("test.csv")
        self.assertEqual(pose_data.shape, (1, len(SELECTED_INDICES), 2))
        self.assertTrue(np.allclose(pose_data[0][0], (0.39822685718536377, 0.3113730251789093)))

    @patch("compare_dance.supabase")
    def test_get_csv_success(self, mock_supabase):
        dummy_content = b"frame,x_7,y_7\n0,0.1,0.2\n"
        mock_supabase.storage.from_.return_value.download.return_value = dummy_content

        with patch("builtins.open", new_callable=mock_open) as m_open:
            result = get_csv("testfile", mock_supabase)
            m_open.assert_called_once()
            self.assertIn("tmp/testfile.csv", result)

    @patch("compare_dance.pose.process")
    def test_process_image_no_landmarks(self, mock_process):
        mock_process.return_value.pose_landmarks = None
        result = process_image("test", 0, np.zeros((480, 640, 3), dtype=np.uint8), 0)
        self.assertEqual(result, 0)

    @patch("compare_dance.pose.process")
    @patch("compare_dance.load_pose_csv")
    def test_process_image_valid(self, mock_load_csv, mock_process):
        mock_load_csv.return_value = np.array([
            [(0.1, 0.2)] * len(SELECTED_INDICES),
            [(0.2, 0.3)] * len(SELECTED_INDICES),
        ])

        mock_landmark = MagicMock()
        mock_landmark.pose_landmarks.landmark = [
            MagicMock(x=0.1, y=0.2) for _ in range(33)
        ]
        mock_process.return_value = mock_landmark

        from compare_dance import motion_cache  # clear cache
        motion_cache.clear()

        result = process_image("test_video", 0, np.zeros((480, 640, 3), dtype=np.uint8), 0)
        self.assertIsInstance(result, int)
        self.assertGreaterEqual(result, 0)


if __name__ == "__main__":
    unittest.main()
