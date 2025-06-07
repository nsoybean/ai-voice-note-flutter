import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../infrastructure/note_service.dart';
import '../domain/note.dart';

class NoteState {
  final Map<String, List<Note>> notes;
  final bool hasMoreData;

  NoteState({required this.notes, required this.hasMoreData});
}

final noteControllerProvider =
    StateNotifierProvider<NoteController, AsyncValue<NoteState>>((ref) {
  return NoteController(noteService: ref.read(noteServiceProvider));
});

class NoteController extends StateNotifier<AsyncValue<NoteState>> {
  final NoteService noteService;
  int _currentPage = 1;
  final int _pageLimit = 10;

  NoteController({required this.noteService})
      : super(const AsyncValue.loading());

  Future<Note?> create() async {
    return await noteService.create();
  }

  Future<void> fetchNotesGroupedByDate() async {
    try {
      state = const AsyncValue.loading();
      final notes = await noteService.fetchNotes(
        page: _currentPage,
        limit: _pageLimit,
      );

      final groupedNotes = <String, List<Note>>{};
      for (final note in notes.notes) {
        final dateKey = note.createdAt.toIso8601String().split('T').first;
        groupedNotes.putIfAbsent(dateKey, () => []).add(note);
      }

      final hasMoreData = notes.meta.page < notes.meta.totalPages;
      state = AsyncValue.data(NoteState(notes: groupedNotes, hasMoreData: hasMoreData));
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> fetchNextPage() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMoreData) return;

    try {
      _currentPage++;
      final notes = await noteService.fetchNotes(
        page: _currentPage,
        limit: _pageLimit,
      );

      if (notes.notes.isEmpty) {
        state = AsyncValue.data(NoteState(
          notes: currentState.notes,
          hasMoreData: false,
        ));
        return;
      }

      final updatedNotes = {...currentState.notes};
      for (final note in notes.notes) {
        final dateKey = note.createdAt.toIso8601String().split('T').first;
        updatedNotes.putIfAbsent(dateKey, () => []).add(note);
      }

      final hasMoreData = notes.meta.page < notes.meta.totalPages;
      state = AsyncValue.data(NoteState(notes: updatedNotes, hasMoreData: hasMoreData));
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

final listNoteProvider = FutureProvider<Map<String, List<Note>>>((ref) async {
  final noteController = ref.read(noteControllerProvider.notifier);
  await noteController.fetchNotesGroupedByDate();
  return noteController.state.value?.notes ?? {}; // Safely access notes
});
