import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/rendering.dart';

import 'finished_screen.dart';
import '../elements/countdown_element.dart';

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
  WebSocketChannel? channel;
  Timer? _frameTimer;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _initializeCamera();
    videoInitFuture = _initializeVideo();
    _frameTimer = Timer.periodic(
      const Duration(milliseconds: 1000),
      (_) => _captureAndSendFrame(),
    );
  }

  void _connectWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse(
        'ws://localhost:8000/ws',
      ),
    );
  }

  Future<void> _captureAndSendFrame() async {
    final frame = await captureCameraFrame();
    if (frame != null && videoController?.value.isPlaying == true) {
      final timestampMs = videoController!.value.position.inMilliseconds;
      final message = {
        'timestamp': timestampMs,
        'image': base64Encode(frame),
      };
      channel?.sink.add(jsonEncode(message));
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

  Future<void> _initializeCamera() async {
    await initializeCameras();
    final camera = cameras.first;
    cameraController =
        CameraController(camera, ResolutionPreset.medium, enableAudio: false);
    await cameraController!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _initializeVideo() async {
    final controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await controller.initialize();
    final start = Duration(seconds: widget.startTime.toInt());
    final end = Duration(seconds: widget.endTime.toInt());
    await controller.seekTo(start);
    controller.setLooping(false);
    controller.addListener(() {
      if (!controller.value.isPlaying) return;
      final current = controller.value.position;
      if (current >= end - const Duration(milliseconds: 100)) {
        channel?.sink.add(jsonEncode({'status': 'done'}));
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
    });
    if (mounted) {
      setState(() {
        videoController = controller;
      });
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    videoController?.dispose();
    channel?.sink.close();
    _frameTimer?.cancel();
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
                      videoController!, widget.startTime, onInterrupted: () {
                    channel?.sink.add(jsonEncode({'status': 'interrupted'}));
                  });
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
                    key: cameraKey, child: CameraPreview(cameraController!))
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
