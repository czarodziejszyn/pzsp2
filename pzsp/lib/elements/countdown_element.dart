import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:pzsp/pages/home_page.dart';

class CountdownBeforeVideo extends StatefulWidget {
  final VideoPlayerController controller;
  final double startTime;
  final VoidCallback onCountdownFinished;
  final VoidCallback onVideoInterrupted;

  const CountdownBeforeVideo(
    this.controller,
    this.startTime, {
    required this.onCountdownFinished,
    required this.onVideoInterrupted,
    super.key,
  });

  @override
  State<CountdownBeforeVideo> createState() => _CountdownBeforeVideoState();
}

class _CountdownBeforeVideoState extends State<CountdownBeforeVideo> {
  int countdown = 3;
  bool showGo = false;
  bool videoStarted = false;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 1) {
        setState(() => countdown--);
      } else if (countdown == 1) {
        setState(() {
          countdown = 0;
          showGo = true;
        });
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            showGo = false;
            videoStarted = true;
          });

          if (widget.controller.value.isInitialized) {
            final startDuration = Duration(seconds: widget.startTime.toInt());
            widget.controller.seekTo(startDuration).then((_) {
              Future.delayed(const Duration(milliseconds: 100), () {
                widget.controller.play();
                widget.onCountdownFinished(); // zacznij wysyłać ramki
              });
            });
          }
        });
      }
    });
  }

  void restartCountdown() {
    widget.onVideoInterrupted();

    setState(() {
      countdown = 3;
      showGo = false;
      videoStarted = false;
    });

    startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: videoStarted
              ? AspectRatio(
                  aspectRatio: widget.controller.value.aspectRatio,
                  child: VideoPlayer(widget.controller),
                )
              : Text(
                  showGo ? 'GO!' : '$countdown',
                  style: const TextStyle(
                      fontSize: 64, fontWeight: FontWeight.bold),
                ),
        ),
        if (videoStarted)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                iconSize: 48,
                icon: const Icon(Icons.stop, color: Colors.white),
                onPressed: () async {
                  await widget.controller.pause();
                  await _showPauseDialog(context);
                },
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showPauseDialog(BuildContext context) async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          elevation: 16,
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 70),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    restartCountdown();
                  },
                  child: const Text("Restart",
                      style: TextStyle(fontSize: 24, color: Colors.white)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 70),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                  onPressed: () {
                    widget.onVideoInterrupted();
                    Navigator.of(context).pop();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,
                    );
                  },
                  child: const Text("Stop",
                      style: TextStyle(fontSize: 24, color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
