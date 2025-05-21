import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddVideoDialog extends StatefulWidget {
  const AddVideoDialog({super.key});

  @override
  State<AddVideoDialog> createState() => _AddVideoDialogState();
}

class _AddVideoDialogState extends State<AddVideoDialog> {
  PlatformFile? _thumbnailFile;
  PlatformFile? _videoFile;
  final _lengthController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  final supabase = Supabase.instance.client;

  Future<void> _pickThumbnail() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() {
        _thumbnailFile = result.files.first;
      });
    }
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4'],
    );
    if (result != null) {
      setState(() {
        _videoFile = result.files.first;
      });
    }
  }

  Future<void> _uploadAndSave() async {
    if (_thumbnailFile == null ||
        _videoFile == null ||
        _lengthController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fill in all the fields')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Upload thumbnail
      final thumbPath =
          'thumbnails/${DateTime.now().millisecondsSinceEpoch}_${_thumbnailFile!.name}';
      final thumbUploadResponse =
          await supabase.storage.from('thumbnails').uploadBinary(
                thumbPath,
                _thumbnailFile!.bytes!,
                fileOptions: FileOptions(cacheControl: '3600', upsert: false),
              );

      // 2. Upload video
      final videoPath =
          'videos/${DateTime.now().millisecondsSinceEpoch}_${_videoFile!.name}';
      final videoUploadResponse =
          await supabase.storage.from('videos').uploadBinary(
                videoPath,
                _videoFile!.bytes!,
                fileOptions: FileOptions(cacheControl: '3600', upsert: false),
              );

      // 3. Get public URLs (bez `.data`)
      final thumbUrl =
          supabase.storage.from('thumbnails').getPublicUrl(thumbPath);
      final videoUrl = supabase.storage.from('videos').getPublicUrl(videoPath);

      // 4. Insert to DB
      final length = double.tryParse(_lengthController.text);
      if (length == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect video length')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 5. Insert record
      await supabase.from('videos').insert({
        'thumbnail': thumbUrl,
        'video': videoUrl,
        'length': length,
        'description': _descriptionController.text.trim(),
      });

      // Jeśli doszliśmy tutaj — sukces
      Navigator.of(context).pop(true);
    } catch (e) {
      print('Error adding video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding video. Try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add new video'),
      content: SizedBox(
        width: 400,
        height: 200,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 400,
                child: ElevatedButton(
                  onPressed: _pickThumbnail,
                  child: Text(_thumbnailFile == null
                      ? 'Select Thumbnail (jpg/png)'
                      : 'Selected: ${_thumbnailFile!.name}'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 400,
                child: ElevatedButton(
                  onPressed: _pickVideo,
                  child: Text(_videoFile == null
                      ? 'Select Video (mp4)'
                      : 'Selected: ${_videoFile!.name}'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _lengthController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Video length (seconds)'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 400,
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
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isLoading ? null : _uploadAndSave,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Add Video'),
        )
      ],
    );
  }
}
