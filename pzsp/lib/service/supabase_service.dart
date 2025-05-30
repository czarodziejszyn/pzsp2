import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pzsp/models/dance.dart';

class SupabaseService {
  Future<List<Dance>> fetchDances() async {
    final response = await Supabase.instance.client.from('dance_info').select();
    return List<Map<String, dynamic>>.from(response)
        .map((map) => Dance.fromMap(map))
        .toList();
  }
}
