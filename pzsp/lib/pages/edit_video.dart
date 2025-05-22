import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditVideoDialog extends StatefulWidget {
  final Map<String, dynamic> video;

  const EditVideoDialog({super.key, required this.video});

  @override
  State<EditVideoDialog> createState() => _EditVideoDialogState();
}

class _EditVideoDialogState extends State<EditVideoDialog> {
  PlatformFile? _newThumbnailFile;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.video['description']);
  }

  Future<void> _pickNewThumbnail() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() {
        _newThumbnailFile = result.files.first;
      });
    }
  }

  String extractStoragePathFromUrl(String url, String bucketName) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    final bucketIndex = segments.indexOf(bucketName);
    if (bucketIndex == -1 || bucketIndex + 1 >= segments.length) {
      throw Exception('Invalid URL structure or bucket not found');
    }
    return segments.sublist(bucketIndex + 1).join('/');
  }

  Future<void> _updateVideo() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description cannot be empty')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? newThumbUrl;

      // Jeśli thumbnail do zmiany
      if (_newThumbnailFile != null) {
        // Usuń stary thumbnail ze storage
        final oldThumbPath = extractStoragePathFromUrl(
          widget.video['thumbnail'],
          'thumbnails',
        );
        await supabase.storage.from('thumbnails').remove([oldThumbPath]);

        // Wgraj nowy
        final newThumbPath =
            '${DateTime.now().millisecondsSinceEpoch}_${_newThumbnailFile!.name}';
        await supabase.storage.from('thumbnails').uploadBinary(
              newThumbPath,
              _newThumbnailFile!.bytes!,
              fileOptions: FileOptions(cacheControl: '3600', upsert: false),
            );

        newThumbUrl =
            supabase.storage.from('thumbnails').getPublicUrl(newThumbPath);
      }

      // Zbuduj dane do aktualizacji
      final updateData = {
        'description': description,
      };

      if (newThumbUrl != null) {
        updateData['thumbnail'] = newThumbUrl;
      }

      await supabase
          .from('videos')
          .update(updateData)
          .eq('id', widget.video['id']);

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating video: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit video information'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _pickNewThumbnail,
                child: Text(_newThumbnailFile == null
                    ? 'Select new thumbnail'
                    : 'Selected: ${_newThumbnailFile!.name}'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateVideo,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Save changes'),
        ),
      ],
    );
  }
}
