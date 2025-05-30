import 'package:pzsp/models/dance.dart';
import 'package:pzsp/service/supabase_service.dart';

class DanceController {
  final SupabaseService _service = SupabaseService();

  Future<List<Dance>> loadDances() async {
    return await _service.fetchDances();
  }
}
