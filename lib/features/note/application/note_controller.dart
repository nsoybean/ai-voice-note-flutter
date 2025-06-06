import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../infrastructure/note_service.dart';
import '../domain/note_user.dart';

final noteControllerProvider = Provider<NoteController>((ref) {
  return NoteController(noteService: ref.read(noteServiceProvider));
});

class NoteController {
  final NoteService noteService;

  NoteController({required this.noteService});

  Future<Note?> create() async {
    return await noteService.create();
  }
}
