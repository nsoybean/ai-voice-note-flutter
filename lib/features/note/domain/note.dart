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

  Note copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  factory Note.fromApiResponse(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
