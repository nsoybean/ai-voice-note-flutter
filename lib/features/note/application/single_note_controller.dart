import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/note.dart';
import '../infrastructure/note_service.dart';

final singleNoteControllerProvider =
    StateNotifierProvider<SingleNoteController, AsyncValue<Note?>>((ref) {
  return SingleNoteController(noteService: ref.read(noteServiceProvider));
});

class SingleNoteController extends StateNotifier<AsyncValue<Note?>> {
  final NoteService noteService;

  SingleNoteController({required this.noteService})
      : super(const AsyncValue.loading());

  Future<void> loadNoteById(String noteId) async {
    state = const AsyncValue.loading();
    try {
      final note = await noteService.fetchNoteById(noteId);
      state = AsyncValue.data(note);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateNoteTitle(String noteId, String newTitle) async {
    try {
      await noteService.updateNoteTitle(noteId, newTitle);
      final updatedNote = state.value?.copyWith(title: newTitle);
      state = AsyncValue.data(updatedNote);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateNoteContent(
      String noteId, Map<String, Object> newContent) async {
    try {
      await noteService.updateNoteContent(noteId, newContent);
      state.value?.copyWith(
          content:
              newContent); // do not update state value here else widget will rebuild, causing editor cursor to reset
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteNoteById(String noteId) async {
    state = const AsyncValue.loading();
    try {
      await noteService.deleteNoteById(noteId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void clearData() {
    state = const AsyncValue.data(null);
  }
}
