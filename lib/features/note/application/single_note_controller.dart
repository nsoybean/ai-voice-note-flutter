import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/note.dart';
import '../infrastructure/note_service.dart';

class SingleNoteState {
  final Note? note;
  final bool isLoading;
  final String? error;

  SingleNoteState({this.note, this.isLoading = false, this.error});

  SingleNoteState copyWith({Note? note, bool? isLoading, String? error}) {
    return SingleNoteState(
      note: note ?? this.note,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final singleNoteControllerProvider =
    StateNotifierProvider<SingleNoteController, SingleNoteState>((ref) {
      return SingleNoteController(noteService: ref.read(noteServiceProvider));
    });

class SingleNoteController extends StateNotifier<SingleNoteState> {
  final NoteService noteService;

  SingleNoteController({required this.noteService}) : super(SingleNoteState());

  Future<void> loadNoteById(String noteId) async {
    state = state.copyWith(isLoading: true);
    try {
      final note = await noteService.fetchNoteById(noteId);
      state = state.copyWith(note: note, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateNoteTitle(String noteId, String newTitle) async {
    try {
      await noteService.updateNoteTitle(noteId, newTitle);
      final updatedNote = state.note?.copyWith(title: newTitle);
      state = state.copyWith(note: updatedNote);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteNoteById(String noteId) async {
    // state = state.copyWith(isLoading: true);
    try {
      await noteService.deleteNoteById(noteId);
      // state = state.copyWith(note: null, isLoading: false);
    } catch (e) {
      // state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
