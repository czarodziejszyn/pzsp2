import 'package:flutter_test/flutter_test.dart';
import 'package:pzsp/models/dance_video_selection.dart'; // popraw ścieżkę

void main() {
  group('DanceVideoSelection model', () {
    test('good values given', () {
      final video = DanceVideoSelection(
        imageUrl: 'https://localhost:8000/image.jpg',
        videoUrl: 'https://localhost:8000/video.mp4',
        title: 'Taniec',
        description: 'Mega taniec',
        length: 42.0,
      );

      expect(video.imageUrl, 'https://localhost:8000/image.jpg');
      expect(video.videoUrl, 'https://localhost:8000/video.mp4');
      expect(video.title, 'Taniec');
      expect(video.description, 'Mega taniec');
      expect(video.length, 42.0);
    });

  });
}
