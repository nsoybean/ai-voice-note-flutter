class Note {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, Object> content;

  Note({
    required this.id,
    this.title = '',
    required this.createdAt,
    required this.updatedAt,
    this.content = const {},
  });

  Note copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, Object>? content,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      content: content ?? this.content,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      content: Map<String, Object>.from(json['jsonContent'] ?? {}),
    );
  }

  factory Note.fromApiResponse(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      content: Map<String, Object>.from(json['content'] as Map? ?? {}),
    );
  }
}
