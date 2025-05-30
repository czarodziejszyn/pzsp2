class Dance {
  final String title;
  final String description;
  final double length;

  Dance({
    required this.title,
    required this.description,
    required this.length,
  });

  factory Dance.fromMap(Map<String, dynamic> map) {
    return Dance(
      title: map['title'],
      description: map['description'],
      length: map['length'],
    );
  }
}
