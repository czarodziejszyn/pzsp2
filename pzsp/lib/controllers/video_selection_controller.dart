import 'package:flutter/material.dart';

class VideoSelectionController extends ChangeNotifier {
  late RangeValues _range;
  final double minRange = 10.0;
  final double maxDuration;

  VideoSelectionController({required this.maxDuration}) {
    _range = RangeValues(0, maxDuration);
  }

  RangeValues get range => _range;

  void updateRange(RangeValues newRange) {
    if (newRange.end - newRange.start >= minRange) {
      _range = newRange;
      notifyListeners();
    }
  }
}
