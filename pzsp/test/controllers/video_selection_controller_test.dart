import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pzsp/controllers/video_selection_controller.dart';

void main() {
  group('VideoSelectionController', () {
    late VideoSelectionController controller;

    setUp(() {
      controller = VideoSelectionController(maxDuration: 100);
    });

    test('initial range is from 0 to maxDuration', () {
      expect(controller.range.start, 0);
      expect(controller.range.end, 100);
    });

    test('updateRange updates range and notifies if difference >= minRange', () {
      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      final newRange = RangeValues(10, 30);
      controller.updateRange(newRange);

      expect(controller.range, newRange);
      expect(notified, true);
    });

    test('updateRange does not update range if difference < minRange', () {
      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      final oldRange = controller.range;
      final newRange = RangeValues(10, 15);
      controller.updateRange(newRange);

      expect(controller.range, oldRange);
      expect(notified, false);
    });
  });
}
