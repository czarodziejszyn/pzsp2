import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pzsp/controllers/dance_controller.dart';
import 'package:video_player/video_player.dart';

class AddVideoDialog extends StatefulWidget {
  const AddVideoDialog({super.key});

  @override
  State<AddVideoDialog> createState() => _AddVideoDialogState();
}

class _AddVideoDialogState extends State<AddVideoDialog> {
  PlatformFile? _thumbnailFile;
  PlatformFile? _videoFile;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  double? _videoDurationSeconds;
  bool _isLoading = false;

  final DanceController _danceController = DanceController();

  Future<void> _pickThumbnail() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg'],
    );
    if (result != null) {
      setState(() => _thumbnailFile = result.files.first);
    }
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4'],
      withData: true, // potrzebne na web
    );

    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      final uri = Uri.dataFromBytes(bytes, mimeType: 'video/mp4');

      final controller = VideoPlayerController.networkUrl(uri);
      await controller.initialize();
      final duration = controller.value.duration;

      print('Video duration: ${duration.inSeconds} seconds');

      setState(() {
        _videoFile = result.files.first;
        _videoDurationSeconds = duration.inSeconds.toDouble();
      });

      controller.dispose();
    }
  }

  Future<void> _uploadAndSave() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final length = _videoDurationSeconds;

    if (_thumbnailFile == null ||
        _videoFile == null ||
        title.isEmpty ||
        description.isEmpty ||
        length == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill in all the fields correctly')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _danceController.addDance(
        title: title,
        description: description,
        length: length,
        thumbnailBytes: _thumbnailFile!.bytes!,
        videoBytes: _videoFile!.bytes!,
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error uploading files. Try again.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add new video'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _pickThumbnail,
                  child: Text(_thumbnailFile == null
                      ? 'Select Thumbnail (jpg)'
                      : 'Selected: ${_thumbnailFile!.name}'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _pickVideo,
                  child: Text(_videoFile == null
                      ? 'Select Video (mp4)'
                      : 'Selected: ${_videoFile!.name} (${_videoDurationSeconds?.toStringAsFixed(0) ?? "?"}s)'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _uploadAndSave,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Video'),
        ),
      ],
    );
  }
}
