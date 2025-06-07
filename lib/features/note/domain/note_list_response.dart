import 'note_user.dart';

class NoteListResponse {
  final List<Note> notes;
  final Meta meta;

  NoteListResponse({required this.notes, required this.meta});

  factory NoteListResponse.fromJson(Map<String, dynamic> json) {
    final notes = (json['data'] as List<dynamic>)
        .map((noteJson) => Note.fromJson(noteJson as Map<String, dynamic>))
        .toList();

    final meta = Meta.fromJson(json['meta'] as Map<String, dynamic>);

    return NoteListResponse(notes: notes, meta: meta);
  }
}

class Meta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Meta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
