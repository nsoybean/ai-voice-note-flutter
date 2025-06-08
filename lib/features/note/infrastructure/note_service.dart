// ONote + HTTP logic
import 'dart:convert';
import 'package:ai_voice_note/core/http_client.dart';
import 'package:ai_voice_note/features/note/domain/note.dart';
import 'package:ai_voice_note/features/note/domain/note_list_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final noteServiceProvider = Provider<NoteService>((ref) {
  final httpClient = HttpClientWrapper(http.Client());
  return NoteService(httpClient: httpClient);
});

class NoteService {
  final HttpClientWrapper httpClient;

  NoteService({required this.httpClient});

  Future<Note?> create() async {
    final res = await httpClient.post(
      Uri.parse('http://127.0.0.1:3000/note/create'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 201) {
      final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
      if (body != null && body is Map<String, dynamic>) {
        return Note.fromApiResponse(body);
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to create note: ${res.statusCode}');
    }
  }

  Future<NoteListResponse> fetchNotes({int page = 1, int limit = 10}) async {
    final res = await httpClient.get(
      Uri.parse('http://127.0.0.1:3000/note/list?page=$page&limit=$limit'),
      headers: {'Accept': 'application/json'},
    );

    if (res.statusCode == 200) {
      final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
      // {data: [], meta: {}}
      if (body is Map<String, dynamic>) {
        return NoteListResponse.fromJson(body);
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to fetch notes: ${res.statusCode}');
    }
  }

  Future<void> updateNoteTitle(String noteId, String newTitle) async {
    final res = await httpClient.put(
      Uri.parse('http://127.0.0.1:3000/note/$noteId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'title': newTitle}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update note title: ${res.statusCode}');
    }
  }

  Future<Note> fetchNoteById(String noteId) async {
    final res = await httpClient.get(
      Uri.parse('http://127.0.0.1:3000/note/$noteId'),
      headers: {'Accept': 'application/json'},
    );

    if (res.statusCode == 200) {
      final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
      if (body != null && body is Map<String, dynamic>) {
        return Note.fromJson(body);
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to fetch note: ${res.statusCode}');
    }
  }
}
