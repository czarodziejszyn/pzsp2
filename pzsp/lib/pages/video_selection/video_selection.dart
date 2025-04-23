import 'package:flutter/material.dart';
import '../video_player/video_player.dart';

class VideoSelectionPage extends StatefulWidget {
  final String selectedImage;
  final String danceStyle;
  
  const VideoSelectionPage({
    super.key,
    required this.selectedImage,
    required this.danceStyle,
  });

  @override
  State<VideoSelectionPage> createState() => _VideoSelectionPageState();
}

class _VideoSelectionPageState extends State<VideoSelectionPage> {
  RangeValues _currentRangeValues = const RangeValues(0, 30);
  final double _maxDuration = 60.0;
  final double _minRange = 10.0;

  void _onNextButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPage(
          imageUrl: widget.selectedImage,
          danceStyle: widget.danceStyle,
          startTime: _currentRangeValues.start,
          endTime: _currentRangeValues.end,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.danceStyle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.selectedImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.error, size: 100),
                    );
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
            ),
            const SizedBox(height: 16),
            RangeSlider(
              values: _currentRangeValues,
              min: 0,
              max: _maxDuration,
              divisions: _maxDuration.toInt(),
              labels: RangeLabels(
                '${_currentRangeValues.start.round()}s',
                '${_currentRangeValues.end.round()}s',
              ),
              onChanged: (RangeValues values) {
                if (values.end - values.start >= _minRange) {
                  setState(() {
                    _currentRangeValues = values;
                  });
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