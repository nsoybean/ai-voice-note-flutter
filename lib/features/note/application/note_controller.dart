import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../infrastructure/note_service.dart';
import '../domain/note.dart';

class NoteState {
  final Map<String, List<Note>> notes;
  final bool hasMoreData;
  final bool
  isLoadingMore; // New property to track loading state for 'Load More'

  NoteState({
    required this.notes,
    required this.hasMoreData,
    this.isLoadingMore = false, // Default to false
  });
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
        // Convert createdAt to local time before extracting the date key
        final dateKey = note.createdAt
            .toLocal() // important !
            .toIso8601String()
            .split('T')
            .first;
        groupedNotes.putIfAbsent(dateKey, () => []).add(note);
      }

      final hasMoreData = notes.meta.page < notes.meta.totalPages;
      state = AsyncValue.data(
        NoteState(notes: groupedNotes, hasMoreData: hasMoreData),
      );
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> fetchNextPage() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMoreData) return;

    try {
      // Set isLoadingMore to true
      state = AsyncValue.data(
        NoteState(
          notes: currentState.notes,
          hasMoreData: currentState.hasMoreData,
          isLoadingMore: true,
        ),
      );

      _currentPage++;
      final notes = await noteService.fetchNotes(
        page: _currentPage,
        limit: _pageLimit,
      );

      if (notes.notes.isEmpty) {
        state = AsyncValue.data(
          NoteState(
            notes: currentState.notes,
            hasMoreData: false,
            isLoadingMore: false, // Reset isLoadingMore
          ),
        );
        return;
      }

      final updatedNotes = {...currentState.notes};
      for (final note in notes.notes) {
        final dateKey = note.createdAt
            .toLocal()
            .toIso8601String()
            .split('T')
            .first;
        updatedNotes.putIfAbsent(dateKey, () => []).add(note);
      }

      final hasMoreData = notes.meta.page < notes.meta.totalPages;
      state = AsyncValue.data(
        NoteState(
          notes: updatedNotes,
          hasMoreData: hasMoreData,
          isLoadingMore: false, // Reset isLoadingMore
        ),
      );
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> refreshNotes() async {
    _currentPage = 1; // Reset to the first page
    await fetchNotesGroupedByDate();
  }
}
