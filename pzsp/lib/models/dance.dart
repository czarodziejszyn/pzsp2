import 'package:pzsp/constants.dart';

class Dance {
  final int id;
  final String title;
  final String description;
  final double length;
  final String thumbnail; // pełny URL
  final String video; // pełny URL

  Dance({
    required this.id,
    required this.title,
    required this.description,
    required this.length,
    required this.thumbnail,
    required this.video,
  });

  factory Dance.fromMap(Map<String, dynamic> map) {
    final title = map['title'] ?? '';
    final basePath = '$supabaseUrl$supabaseBuckerDir';

    return Dance(
      id: map['id'] ?? -1,
      title: title,
      description: map['description'] ?? '',
      length: (map['length'] ?? 0).toDouble(),
      thumbnail: '$basePath/thumbnails/$title.jpg',
      video: '$basePath/videos/$title.mp4',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'length': length,
      'thumbnail': thumbnail,
      'video': video,
    };
  }

  Dance copyWith({String? description, String? thumbnail}) {
    return Dance(
      id: id,
      title: title,
      description: description ?? this.description,
      length: length,
      thumbnail: thumbnail ?? this.thumbnail,
      video: video,
    );
  }
}
