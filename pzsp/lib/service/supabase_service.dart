import 'package:pzsp/models/dance.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final client = Supabase.instance.client;

  Future<List<Dance>> fetchDances() async {
    final response = await client.from('dance_info').select();
    final data = response as List<dynamic>;
    return data.map((item) => Dance.fromMap(item)).toList();
  }

  Future<void> updateDance(Dance dance) async {
    await client.from('dance_info').update({
      'description': dance.description,
    }).eq('id', dance.id);
  }

  Future<void> deleteDance(Dance dance) async {
    // remove files based on generated URLs
    await client.storage.from('thumbnails').remove(['${dance.title}.jpg']);
    await client.storage.from('videos').remove(['${dance.title}.mp4']);
    await client.from('dance_info').delete().eq('id', dance.id);
  }
}
