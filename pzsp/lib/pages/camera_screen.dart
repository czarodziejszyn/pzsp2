import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';
import 'package:video_player/video_player.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

import 'finished_screen.dart';
import 'package:pzsp/elements/countdown_element.dart';

late List<CameraDescription> cameras;

Future<void> initializeCameras() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
}

class CameraScreen extends StatefulWidget {
  final String videoUrl;
  final double startTime;
  final double endTime;
  final String title;

  const CameraScreen({
    super.key,
    required this.videoUrl,
    required this.startTime,
    required this.endTime,
    required this.title,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? cameraController;
  VideoPlayerController? videoController;
  late Future<void> videoInitFuture;
  final GlobalKey cameraKey = GlobalKey();
  late IO.Socket channel;
  Timer? _frameTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    videoInitFuture = _initializeVideo();
    _connectSocket();
  }

  void _connectSocket() {
    channel = IO.io(
        'http://localhost:8000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    channel.connect();
    channel.emit(
        'status', jsonEncode({'status': 'start', 'time': widget.startTime, 'title': widget.title}));
  }

  void _startSendingFrames() {
    _frameTimer = Timer.periodic(
        const Duration(milliseconds: 200), (_) => _captureAndSendFrame());
  }

  Future<void> _captureAndSendFrame() async {
    if (!(videoController?.value.isInitialized ?? false)) return;

    final currentPositionMs = videoController!.value.position.inMilliseconds;
    final frame = await captureCameraFrame();

    if (frame != null && channel.connected == true) {
      final base64Image = base64Encode(frame);
      final message = jsonEncode({
        'timestamp_ms': currentPositionMs,
        'image': base64Image,
      });
      channel.emit('frame', message);
    }
  }

  Future<Uint8List?> captureCameraFrame() async {
    try {
      final boundary = cameraKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 0.5);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
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
      setState(() => videoController = controller);
    }

    controller.addListener(() {
      final current = controller.value.position;
      if (current >= end) {
        _frameTimer?.cancel();

        controller.pause();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FinishedScreen(
              selectedVideo: widget.videoUrl,
              startTime: widget.startTime,
              endTime: widget.endTime,
              channel: channel,
              title: widget.title,
            ),
          ),
        );
      }
    });
  }

  void handleInterrupted() {
    _frameTimer?.cancel();
    channel.emit('status', jsonEncode({'status': 'interrupted'}));
    channel.dispose();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    videoController?.dispose();
    _frameTimer?.cancel();
    channel.dispose();
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
                    onCountdownFinished: _startSendingFrames,
                    onVideoInterrupted: handleInterrupted,
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
