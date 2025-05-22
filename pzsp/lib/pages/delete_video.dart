import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteVideoDialog extends StatefulWidget {
  final List<Map<String, dynamic>> videos;

  const DeleteVideoDialog({super.key, required this.videos});

  @override
  State<DeleteVideoDialog> createState() => _DeleteVideoDialogState();
}

class _DeleteVideoDialogState extends State<DeleteVideoDialog> {
  Map<String, dynamic>? _selectedVideo;
  bool _isDeleting = false;
  final supabase = Supabase.instance.client;

  Future<void> _deleteVideo() async {
    if (_selectedVideo == null) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      // 1. Usuń plik thumbnail
      final thumbUrl = _selectedVideo!['thumbnail'] as String;
      final thumbPath = Uri.parse(thumbUrl).pathSegments.skip(1).join('/');
      // Pomijamy pierwszy segment bo to "/" na początku, dostosuj jeśli inna struktura

      await supabase.storage.from('thumbnails').remove([thumbPath]);

      // 2. Usuń plik video
      final videoUrl = _selectedVideo!['video'] as String;
      final videoPath = Uri.parse(videoUrl).pathSegments.skip(1).join('/');

      await supabase.storage.from('videos').remove([videoPath]);

      // 3. Usuń rekord z tabeli
      final videoId = _selectedVideo!['id']; // Załóżmy, że masz id w tabeli
      await supabase.from('videos').delete().eq('id', videoId);

      Navigator.of(context).pop(true); // Powiedz, że usunieto
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting video. Try again.')),
      );
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select video to delete'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<Map<String, dynamic>>(
              isExpanded: true,
              hint: const Text('Select video'),
              value: _selectedVideo,
              items: widget.videos.map((video) {
                return DropdownMenuItem(
                  value: video,
                  child: Text(video['description'] ?? 'No description'),
                );
              }).toList(),
              onChanged: (val) => setState(() {
                _selectedVideo = val;
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed:
              _isDeleting || _selectedVideo == null ? null : _deleteVideo,
          child: _isDeleting
              ? const CircularProgressIndicator()
              : const Text('Delete'),
        ),
      ],
    );
  }
}
