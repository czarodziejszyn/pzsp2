import 'package:flutter_test/flutter_test.dart';
import 'package:pzsp/models/dance.dart'; 

void main() {
  group('Dance model', () {
    test('ok dance desc', () {
      final map = {
        'title': 'Dance',
        'description': 'Latin dance',
        'length': 60.0,
      };

      final dance = Dance.fromMap(map);

      expect(dance.title, 'Dance');
      expect(dance.description, 'Latin dance');
      expect(dance.length, 60.0);
    });

    test('missing fields', () {
      final invalidMap = {
        'title': 'Taniec',
      };

      expect(() => Dance.fromMap(invalidMap), throwsA(isA<TypeError>()));
    });
  });
}