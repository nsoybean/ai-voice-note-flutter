import 'dart:async';
import 'dart:convert';
import 'package:ai_voice_note/features/note/domain/note.dart';
import 'package:ai_voice_note/features/note/presentation/editor.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:intl/intl.dart';

import 'package:ai_voice_note/features/home/presentation/home_page.dart';
import 'package:flutter/material.dart';
import 'package:ai_voice_note/theme/brand_text_styles.dart';
import 'package:ai_voice_note/theme/brand_colors.dart';
import 'package:ai_voice_note/theme/brand_radius.dart';
import 'package:ai_voice_note/theme/brand_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_voice_note/features/note/application/note_controller.dart';
import 'package:ai_voice_note/features/note/application/single_note_controller.dart';

class NoteEditorPage extends ConsumerStatefulWidget {
  final String noteId;
  final String? title;

  const NoteEditorPage({Key? key, required this.noteId, this.title = ''})
      : super(key: key);

  @override
  ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
  late TextEditingController _titleController;
  EditorState? _editorState;
  String? _lastSavedContentString; // Cache for the last saved content

  @override
  void initState() {
    super.initState();

    // title controller
    _titleController = TextEditingController();

    // Trigger the load when page opens
    Future.microtask(() async {
      final notifier = ref.read(singleNoteControllerProvider.notifier);

      // clear state
      notifier.clearData();

      // refetch
      notifier.loadNoteById(widget.noteId);
    });
  }

  @override
  void dispose() {
    ref.invalidate(singleNoteControllerProvider);
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final singleNoteState = ref.watch(
        singleNoteControllerProvider); // 'watch' rebuilds on state changes

    print('🚀 content ${singleNoteState.value?.content}');

    // Update the title in the TextEditingController if the state has data and the title is different
    if (singleNoteState.value != null) {
      final noteTitle = singleNoteState.value?.title ?? '';
      if (_titleController.text != noteTitle) {
        final currentPosition = _titleController.selection;
        _titleController.text = noteTitle;
        _titleController.selection = currentPosition;
      }
    }

    return Scaffold(
      backgroundColor: BrandColors.backgroundLight,
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: ReusableAppBar(
              showToggle: false,
              showBackIcon: true,
              onBackCallback: () {
                ref.read(noteControllerProvider.notifier).refreshNotes();
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: BrandSpacing.xl,
                horizontal: BrandSpacing.xxl,
              ),
              child: _buildEditorOrError(singleNoteState, context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorOrError(AsyncValue<Note?> state, BuildContext context) {
    return state.when(
      data: (note) {
        if (note == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 64, color: BrandColors.subtext),
                const SizedBox(height: BrandSpacing.md),
                Text(
                  "Note not found",
                  style:
                      BrandTextStyles.h2.copyWith(color: BrandColors.textDark),
                ),
                const SizedBox(height: BrandSpacing.sm),
                Text(
                  "We couldn’t find the note you’re looking for.\nIt may have been deleted or the link is incorrect.",
                  style: BrandTextStyles.small,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: BrandSpacing.lg),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BrandRadius.medium),
                    padding: const EdgeInsets.symmetric(
                      horizontal: BrandSpacing.xl,
                      vertical: BrandSpacing.sm,
                    ),
                  ),
                  child: const Text("Back to Notes"),
                ),
              ],
            ),
          );
        }

        // Init editor state when the note loads
        _editorState = EditorState(
          document: note.content.isNotEmpty
              ? Document.fromJson(note.content)
              : Document.blank(),
        );

        _lastSavedContentString = _editorState?.document.toJson().toString();

        return Align(
          alignment: Alignment.centerLeft,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) {
                        _onTitleDefocused();
                      }
                    },
                    child: TextField(
                      controller: _titleController,
                      onEditingComplete: _onTitleDefocused,
                      decoration: InputDecoration(
                        hintText:
                            note.title.isNotEmpty ? note.title : 'Untitled',
                        hintStyle: BrandTextStyles.h2.copyWith(
                          color: BrandColors.placeholder,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: BrandTextStyles.h2,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: BrandSpacing.xs),
                  Text(
                    'Created At: ${DateFormat('MMM dd, yyyy hh:mm a').format(note.createdAt.toLocal())}',
                    style: BrandTextStyles.small
                        .copyWith(color: BrandColors.subtext),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: BrandSpacing.lg),
                  Expanded(
                    child: SafeArea(
                      maintainBottomViewPadding: true,
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus) {
                            final currentContentString =
                                _editorState!.document.toJson().toString();
                            if (currentContentString !=
                                _lastSavedContentString) {
                              // uncomment to debug
                              // print('🚀 Saving changed content');
                              ref
                                  .read(singleNoteControllerProvider.notifier)
                                  .updateNoteContent(widget.noteId,
                                      _editorState!.document.toJson());
                              _lastSavedContentString =
                                  _editorState!.document.toJson().toString();
                            }
                          }
                        },
                        child: MyTextEditor(
                          jsonString: Future.value(
                              jsonEncode(_editorState!.document.toJson())),
                          onEditorStateChange: (newState) {
                            _editorState = newState;
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'Error: $error',
          style: BrandTextStyles.h2.copyWith(color: BrandColors.error),
        ),
      ),
    );
  }

  void _onTitleDefocused() {
    final newTitle = _titleController.text.trim();
    final singleNoteState = ref.read(singleNoteControllerProvider);

    if (singleNoteState.value != null &&
        newTitle.isNotEmpty &&
        newTitle != singleNoteState.value!.title.trim()) {
      ref
          .read(singleNoteControllerProvider.notifier)
          .updateNoteTitle(widget.noteId, newTitle);
    }
  }
}
