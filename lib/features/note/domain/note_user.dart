class Note {
  final String id;
  final String title;
  final DateTime createdAt;

  Note({required this.id, required this.title, required this.createdAt});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  factory Note.fromApiResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return Note(
      id: data['id'] as String,
      title: data['title'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }
}
