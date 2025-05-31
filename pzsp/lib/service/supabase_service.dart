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

  Future<void> updateDance(Dance dance, {bool updateThumbnail = false}) async {
    final data = {'description': dance.description};

    if (updateThumbnail) {
      data['thumbnail'] = dance.thumbnail;
    }

    await client.from('dance_info').update(data).eq('id', dance.id);
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

  /// Upload new thumbnail and update dance info
  Future<Dance> uploadThumbnailAndUpdateDance(
      Dance dance, Uint8List fileBytes) async {
    final bucket = 'thumbnails';
    final filePath = '${dance.title}.jpg';

    // Usuń starą miniaturkę
    await client.storage.from(bucket).remove([filePath]);

    // Upload nowej miniaturki
    await client.storage.from(bucket).uploadBinary(
          filePath,
          fileBytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

    // Zbuduj nowy URL miniaturki
    final newThumbnailUrl =
        '${supabaseUrl}${supabaseBuckerDir}/$bucket/$filePath';

    // Zaktualizuj model z nowym URL
    final updatedDance = dance.copyWith(thumbnail: newThumbnailUrl);

    // Zapisz w bazie
    await updateDance(updatedDance);

    return updatedDance;
  }
}
