import 'package:pzsp/models/dance.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pzsp/constants.dart';
import 'dart:typed_data';

class SupabaseService {
  final client = Supabase.instance.client;

  Future<List<Dance>> fetchDances() async {
    final response = await client.from('dance_info').select();
    final data = response as List<dynamic>;
    return data.map((item) => Dance.fromMap(item)).toList();
  }

  /// Edytuje opis, a jeśli trzeba — podmienia thumbnail w Storage
  Future<void> updateDance(Dance dance, {Uint8List? newThumbnailBytes}) async {
    if (newThumbnailBytes != null) {
      final filePath = '${dance.title}.jpg';
      try {
        await client.storage.from('thumbnails').remove([filePath]);
        await client.storage.from('thumbnails').uploadBinary(
              filePath,
              newThumbnailBytes,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: true),
            );
      } catch (e) {
        throw Exception('Błąd przy usuwaniu plików lub rekordu: $e');
      }
    }

    await client.from('dance_info').update({
      'description': dance.description,
    }).eq('id', dance.id);
  }

  Future<void> deleteDance(Dance dance) async {
    try {
      await client.storage.from('thumbnails').remove(['${dance.title}.jpg']);
      await client.storage.from('videos').remove(['${dance.title}.mp4']);
      await client.storage.from('pose-points').remove(['${dance.title}.csv']);

      await client.from('dance_info').delete().eq('id', dance.id);
    } catch (e) {
      throw Exception('Błąd przy usuwaniu plików lub rekordu: $e');
    }
  }

  Future<void> uploadDance({
    required String title,
    required String description,
    required double length,
    required Uint8List thumbnailBytes,
    required Uint8List videoBytes,
  }) async {
    final thumbnailPath = '$title.jpg';
    final videoPath = '$title.mp4';

    // 1. Upload thumbnail
    await client.storage.from('thumbnails').uploadBinary(
          thumbnailPath,
          thumbnailBytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

    // 2. Upload video
    await client.storage.from('videos').uploadBinary(
          videoPath,
          videoBytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

    // 3. Insert to database
    await client.from('dance_info').insert({
      'title': title,
      'description': description,
      'length': length,
      // thumbnail i video NIE są trzymane w bazie
    });
  }
}
