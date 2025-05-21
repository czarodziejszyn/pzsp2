import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:pzsp/elements/countdown_element.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'finished_screen.dart';

late List<CameraDescription> cameras;

Future<void> initializeCameras() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
}

class CameraScreen extends StatefulWidget {
  final String videoUrl;
  final double startTime;
  final double endTime;

  const CameraScreen({
    super.key,
    required this.videoUrl,
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
  final GlobalKey cameraKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    videoInitFuture = _initializeVideo();

    Timer _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _captureAndSendFrame(),
    );
  }

  Future<void> _captureAndSendFrame() async {
    final frame = await captureCameraFrame();
    if (frame != null) {
      await sendToBackend(frame);
    }
  }

  Future<Uint8List?> captureCameraFrame() async {
    try {
      final boundary =
          cameraKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error capturing frame: $e');
      return null;
    }
  }

  Future<void> sendToBackend(Uint8List imageBytes) async {
    final uri = Uri.parse(
      'http://localhost:8000/analyze-frame',
    ); //TODO tutaj jest api miejsce

    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('image', imageBytes,
          filename: 'frame.png'));

    request.send();
  }

  Future<void> _initializeCamera() async {
    await initializeCameras();
    final camera = cameras.first;
    cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await cameraController!.initialize();

    if (mounted) setState(() {});
  }

  Future<void> _initializeVideo() async {
    final controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await controller.initialize();

    final start = Duration(seconds: widget.startTime.toInt());
    final end = Duration(seconds: widget.endTime.toInt());

    controller.setLooping(false);
    await controller.seekTo(start);

    if (mounted) {
      setState(() {
        videoController = controller;
      });
    }

    controller.addListener(
      () {
        if (!controller.value.isPlaying) return;

        final current = controller.value.position;
        if (current >= end - const Duration(milliseconds: 100)) {
          controller.pause();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => FinishedScreen(
                  selectedVideo: widget.videoUrl,
                  startTime: widget.startTime,
                  endTime: widget.endTime,
                ),
              ),
            );
          }
        }
      },
    );
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
                  return CountdownBeforeVideo(
                    videoController!,
                    widget.startTime,
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Container(width: 1, color: Colors.black),
          Expanded(
            child: cameraController?.value.isInitialized ?? false
                ? RepaintBoundary(
                    key: cameraKey,
                    child: CameraPreview(cameraController!),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
