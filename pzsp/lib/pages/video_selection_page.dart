import 'package:flutter/material.dart';
import 'package:pzsp/models/dance_video_selection.dart';
import 'package:pzsp/pages/camera_screen.dart';

class VideoSelectionPage extends StatefulWidget {
  final DanceVideoSelection selection;

  const VideoSelectionPage({super.key, required this.selection});

  @override
  State<VideoSelectionPage> createState() => _VideoSelectionPageState();
}

class _VideoSelectionPageState extends State<VideoSelectionPage> {
  late RangeValues _currentRangeValues;
  final double _minRange = 10.0;

  @override
  void initState() {
    super.initState();
    final max = widget.selection.length.toDouble();
    _currentRangeValues = RangeValues(0, max);
  }

  void _onNextButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          selection: widget.selection,
          startTime: _currentRangeValues.start,
          endTime: _currentRangeValues.end,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.selection;

    return Scaffold(
      appBar: AppBar(title: Text(s.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  s.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.error, size: 100));
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Select video fragment (${_currentRangeValues.end - _currentRangeValues.start} seconds)',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            RangeSlider(
              values: _currentRangeValues,
              min: 0,
              max: s.length,
              divisions: s.length.toInt(),
              labels: RangeLabels(
                '${_currentRangeValues.start.round()}s',
                '${_currentRangeValues.end.round()}s',
              ),
              onChanged: (values) {
                if (values.end - values.start >= _minRange) {
                  setState(() => _currentRangeValues = values);
                }
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _onNextButtonPressed,
              icon: const Icon(Icons.play_arrow, size: 30),
              label: const Text('Play Selected Fragment', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

