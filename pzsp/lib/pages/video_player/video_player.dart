import 'package:flutter/material.dart';

class VideoPlayerPage extends StatelessWidget {
  final String videoUrl;
  final String danceDescription;
  final double startTime;
  final double endTime;
  
  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.danceDescription,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playing: $danceDescription'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    videoUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, size: 100),
                      );
                    },
                  ),
                ),
              ),
            ),
            Text(
              'Playing from ${startTime.round()}s to ${endTime.round()}s',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              'Duration: ${(endTime - startTime).round()} seconds',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}