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

  late WidgetBuilder _widgetBuilder;
  late EditorState _editorState;
  late Future<String> _jsonString;

  @override
  void initState() {
    super.initState();

    _widgetBuilder = (context) => MyTextEditor(
          jsonString: Future<String>.value(jsonEncode(
            EditorState.blank(withInitialText: true).document.toJson(),
          ).toString()),
          onEditorStateChange: (editorState) {
            _editorState = EditorState.blank(withInitialText: true);
            print('🚀🚀🚀 ${jsonEncode(_editorState.document.toJson())}');
          },
        );

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
    _titleController.dispose();
    super.dispose();
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
                  child: _widgetBuilder(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
