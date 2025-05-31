import 'package:pzsp/models/dance.dart';
import 'package:pzsp/service/supabase_service.dart';
import 'dart:typed_data';

class DanceController {
  final SupabaseService _service = SupabaseService();

  Future<List<Dance>> loadDances() async {
    return await _service.fetchDances();
  }

  Future<Dance> editDance(Dance dance,
      {String? newDescription, Uint8List? newThumbnailBytes}) async {
    Dance updatedDance = dance;

    // Jeśli jest nowy opis, zaktualizuj model
    if (newDescription != null) {
      updatedDance = updatedDance.copyWith(description: newDescription);
    }

    if (newThumbnailBytes != null) {
      // Upload miniaturki i aktualizacja modelu i bazy w service
      updatedDance = await _service.uploadThumbnailAndUpdateDance(
          updatedDance, newThumbnailBytes);
    } else {
      // Aktualizacja tylko opisu jeśli miniaturka nie zmieniana
      await _service.updateDance(updatedDance);
    }

    return updatedDance;
  }

  Future<void> deleteDance(Dance dance) async {
    await _service.deleteDance(dance);
  }
}
