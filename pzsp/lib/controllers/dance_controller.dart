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

    await _service.updateDance(updatedDance,
        newThumbnailBytes: newThumbnailBytes);

    return updatedDance;
  }

  Future<void> deleteDance(Dance dance) async {
    await _service.deleteDance(dance);
  }

  Future<void> addDance({
    required String title,
    required String description,
    required double length,
    required Uint8List thumbnailBytes,
    required Uint8List videoBytes,
  }) async {
    await _service.uploadDance(
      title: title,
      description: description,
      length: length,
      thumbnailBytes: thumbnailBytes,
      videoBytes: videoBytes,
    );
  }
}
