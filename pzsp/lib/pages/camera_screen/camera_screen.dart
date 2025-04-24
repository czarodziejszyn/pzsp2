import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../home_page/home_page.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

late List<CameraDescription> cameras;

Future<void> initializeCameras() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
}

class CameraScreen extends StatefulWidget {
  final String videoUrl;
  final String danceDescription;
  final double startTime;
  final double endTime;

  const CameraScreen({
    super.key,
    required this.videoUrl,
    required this.danceDescription,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? cameraController;
  VideoPlayerController? videoController;
  late Future<void> videoInitFuture;

  @override
  void initState() {
    super.initState();
    initCamera();
    videoInitFuture = initVideo();
  }

  Future<void> initCamera() async {
    await initializeCameras();

    final camera = cameras.first;
    cameraController = CameraController(camera, ResolutionPreset.medium);
    await cameraController!.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> initVideo() async {
    final controller = VideoPlayerController.asset(
      'assets/videos/my_video.mp4',
    );
    await controller.initialize();
    if (mounted) {
      setState(() {
        videoController = controller;
      });
    }
    controller.setLooping(false);

    final Duration segmentDuration = Duration(
      milliseconds: ((widget.endTime - widget.startTime) * 1000).round(),
    );

    controller.addListener(() {
      final isFinished = controller.value.position >= segmentDuration;
      if (isFinished && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FinishedScreen()),
        );
      }
    });

    setState(() {
      videoController = controller;
    });
  }

  @override
  void dispose() {
    cameraController?.dispose();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: FutureBuilder(
              future: videoInitFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    videoController != null) {
                  return CountdownBeforeVideo(videoController!);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Container(width: 1, color: Colors.black),
          Expanded(
            child: cameraController != null &&
                    cameraController!.value.isInitialized
                ? CameraPreview(cameraController!)
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}

class FinishedScreen extends StatelessWidget {
  const FinishedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Finished")),
      body: const Center(
        child: Text(
          "Video Finished.",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class CountdownBeforeVideo extends StatefulWidget {
  final VideoPlayerController controller;

  const CountdownBeforeVideo(this.controller, {super.key});

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
        setState(() {
          countdown--;
        });
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
            widget.controller.seekTo(Duration.zero).then((_) {
              // opóźnienie, aby upewnić się, że kontroler jest gotowy do odtwarzania
              Future.delayed(const Duration(milliseconds: 100), () {
                widget.controller.play();
              });
            });
          }
        });
      }
    });
  }

  void restartCountdown() {
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
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
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
                icon: Icon(Icons.pause, color: Colors.white),
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
    // Sprawdzenie czy widget jest nadal zamontowany
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 16,
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Przycisk "Restart"
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 70),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Zamknięcie popup
                    restartCountdown();
                  },
                  child: const Text(
                    "Restart",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20), // Odstęp między przyciskami
                // Przycisk "Stop"
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 70),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Nawigowanie do HomePage

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                      (Route<dynamic> route) =>
                          false, // usuwa wszystkie wcześniejsze strony
                    );
                  },
                  child: const Text(
                    "Stop",
                    style: TextStyle(fontSize: 24, color: Colors.white),
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
