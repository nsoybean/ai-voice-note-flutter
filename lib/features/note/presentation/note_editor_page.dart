import 'dart:async';
import 'dart:convert';
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

  @override
  void initState() {
    super.initState();

    // title controller
    _titleController = TextEditingController();

    // Trigger the load when page opens
    Future.microtask(() async {
      ref
          .read(singleNoteControllerProvider.notifier)
          .loadNoteById(widget.noteId);
    });
  }

  @override
  void dispose() {
    // Clear all data when the widget is disposed
    ref.read(singleNoteControllerProvider.notifier).clearData();
    _titleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NoteEditorPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.noteId != widget.noteId) {
      // Reset the editor state when the noteId changes
      _editorState = null;
      // Trigger the load for the new noteId
      Future.microtask(() async {
        await ref
            .read(singleNoteControllerProvider.notifier)
            .loadNoteById(widget.noteId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final singleNoteState = ref.watch(singleNoteControllerProvider);

    if (singleNoteState.note != null &&
        _titleController.text != singleNoteState.note!.title) {
      _titleController.text = singleNoteState.note!.title;
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

  Widget _buildEditorOrError(SingleNoteState state, BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.note == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: BrandColors.subtext),
            const SizedBox(height: BrandSpacing.md),
            Text(
              "Note not found",
              style: BrandTextStyles.h2.copyWith(color: BrandColors.textDark),
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
                shape: RoundedRectangleBorder(borderRadius: BrandRadius.medium),
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
    _editorState ??= EditorState(
      document: Document.fromJson(state.note!.content),
    );

    return Align(
      alignment:
          Alignment.centerLeft, // Align all items in the column to the left
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 900), // Set max width to 800
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Ensure children are aligned left
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
                    hintText: state.note!.title.isNotEmpty
                        ? state.note!.title
                        : 'Untitled',
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
                'Created At: ${DateFormat('MMM dd, yyyy hh:mm a').format(state.note!.createdAt.toLocal())}',
                style: BrandTextStyles.small,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: BrandSpacing.lg),
              Expanded(
                child: SafeArea(
                    maintainBottomViewPadding: true,
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          final newContent = _editorState!.document.toJson();
                          final singleNoteState =
                              ref.read(singleNoteControllerProvider);

                          if (singleNoteState.note != null &&
                              jsonEncode(newContent) !=
                                  jsonEncode(singleNoteState.note!.content)) {
                            ref
                                .read(singleNoteControllerProvider.notifier)
                                .updateNoteContent(widget.noteId, newContent);
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
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTitleDefocused() {
    final newTitle = _titleController.text.trim();
    final singleNoteState = ref.read(singleNoteControllerProvider);

    if (newTitle.isNotEmpty &&
        singleNoteState.note != null &&
        newTitle != singleNoteState.note!.title) {
      ref
          .read(singleNoteControllerProvider.notifier)
          .updateNoteTitle(widget.noteId, newTitle);
    }
  }
}
