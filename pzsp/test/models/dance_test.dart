import 'package:flutter_test/flutter_test.dart';
import 'package:pzsp/models/dance.dart';
import 'package:pzsp/constants.dart';

void main() {
  group('Dance model', () {
    test('Correct map creates valid Dance object', () {
      final map = {
        'id': 1,
        'title': 'Salsa',
        'description': 'Energetic latin dance',
        'length': 75,
      };

      final dance = Dance.fromMap(map);

      expect(dance.id, 1);
      expect(dance.title, 'Salsa');
      expect(dance.description, 'Energetic latin dance');
      expect(dance.length, 75.0);
      expect(
        dance.thumbnail,
        '$supabaseUrl$supabaseBuckerDir/thumbnails/Salsa.jpg',
      );
      expect(
        dance.video,
        '$supabaseUrl$supabaseBuckerDir/videos/Salsa.mp4',
      );
    });

    test('Missing optional fields uses defaults', () {
      final map = {
        'id': 2,
        'title': 'Tango',
      };

      final dance = Dance.fromMap(map);

      expect(dance.id, 2);
      expect(dance.title, 'Tango');
      expect(dance.description, '');
      expect(dance.length, 0.0);
      expect(
        dance.thumbnail,
        '$supabaseUrl$supabaseBuckerDir/thumbnails/Tango.jpg',
      );
      expect(
        dance.video,
        '$supabaseUrl$supabaseBuckerDir/videos/Tango.mp4',
      );
    });

    test('copyWith updates only provided fields', () {
      final original = Dance(
        id: 3,
        title: 'Waltz',
        description: 'Elegant dance',
        length: 90.0,
        thumbnail: 'thumb1.jpg',
        video: 'Waltz.mp4',
      );

      final modified = original.copyWith(
        description: 'Slow elegant dance',
        thumbnail: 'Waltz.jpg',
      );

      expect(modified.id, 3);
      expect(modified.title, 'Waltz');
      expect(modified.description, 'Slow elegant dance');
      expect(modified.length, 90.0);
      expect(modified.thumbnail, 'Waltz.jpg');
      expect(modified.video, 'Waltz.mp4');
    });
  });
}
