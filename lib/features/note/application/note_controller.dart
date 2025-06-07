import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../infrastructure/note_service.dart';
import '../domain/note_user.dart';

final noteControllerProvider =
    StateNotifierProvider<NoteController, AsyncValue<Map<String, List<Note>>>>((
      ref,
    ) {
      return NoteController(noteService: ref.read(noteServiceProvider));
    });

class NoteController
    extends StateNotifier<AsyncValue<Map<String, List<Note>>>> {
  final NoteService noteService;

  NoteController({required this.noteService})
    : super(const AsyncValue.loading());

  Future<Note?> create() async {
    return await noteService.create();
  }

  Future<void> fetchNotesGroupedByDate() async {
    try {
      state = const AsyncValue.loading();
      final notes = await noteService.fetchNotes();

      // Group notes by date (e.g., "2025-06-07")
      final groupedNotes = <String, List<Note>>{};
      for (final note in notes.notes) {
        final dateKey = note.createdAt.toIso8601String().split('T').first;
        groupedNotes.putIfAbsent(dateKey, () => []).add(note);
      }

      state = AsyncValue.data(groupedNotes);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

final listNoteProvider = FutureProvider<Map<String, List<Note>>>((ref) async {
  final noteController = ref.read(noteControllerProvider.notifier);
  await noteController.fetchNotesGroupedByDate();
  return noteController.state.whenData((value) => value).value ?? {};
});
