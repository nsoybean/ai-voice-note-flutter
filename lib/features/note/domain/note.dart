class Note {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    this.title = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  factory Note.fromApiResponse(Map<String, dynamic> json) {
    if (json.containsKey('data')) {
      final data = json['data'] as Map<String, dynamic>;
      return Note(
        id: data['id'] as String,
        title: data['title'] as String? ?? '',
        createdAt: DateTime.parse(data['createdAt'] as String),
        updatedAt: DateTime.parse(data['updatedAt'] as String),
      );
    } else {
      throw Exception('Invalid response format: Missing "data" key');
    }
  }
}
