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
                widget.onCountdownFinished();
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
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 58, 92, 153),
                  ),
                ),
        ),
        if (videoStarted)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color.fromARGB(200, 0, 0, 0),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(2, 2),
                  )
                ],
              ),
              child: IconButton(
                iconSize: 36,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          elevation: 16,
          child: Container(
            padding: const EdgeInsets.all(24),
            height: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(180, 60),
                    backgroundColor: const Color.fromARGB(255, 58, 92, 153),
                    iconColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.restart_alt, size: 28),
                  onPressed: () {
                    Navigator.of(context).pop();
                    restartCountdown();
                  },
                  label: const Text(
                    "Restart",
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(180, 60),
                    backgroundColor: const Color.fromARGB(255, 180, 50, 50),
                    iconColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.stop_circle, size: 28),
                  onPressed: () {
                    widget.onVideoInterrupted();
                    Navigator.of(context).pop();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,
                    );
                  },
                  label: const Text(
                    "End Dance",
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

