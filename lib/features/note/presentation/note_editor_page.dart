import 'dart:async';
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
import 'package:fleather/fleather.dart';

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
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<EditorState> _editorKey = GlobalKey();
  FleatherController? _controller;

  @override
  void initState() {
    super.initState();

    // Initialize the title controller
    _titleController = TextEditingController();
    _initFleatherController();

    // Trigger the load when page opens
    Future.microtask(() async {
      ref
          .read(singleNoteControllerProvider.notifier)
          .loadNoteById(widget.noteId);
    });
  }

  Future<void> _initFleatherController() async {
    print("Initializing FleatherController...");
    final heuristics = ParchmentHeuristics(
      formatRules: [],
      insertRules: [ForceNewlineForInsertsAroundInlineImageRule()],
      deleteRules: [],
    ).merge(ParchmentHeuristics.fallback);
    final doc = ParchmentDocument.fromJson([
      {"insert": "\n"},
    ], heuristics: heuristics);
    _controller = FleatherController(document: doc);
    print("FleatherController initialized successfully.");
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _onTitleChanged(String newTitle) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref
          .read(singleNoteControllerProvider.notifier)
          .updateNoteTitle(widget.noteId, newTitle);
    });
  }

  @override
  Widget build(BuildContext context) {
    final singleNoteState = ref.watch(singleNoteControllerProvider);

    if (singleNoteState.note != null) {
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
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Ensure children are aligned left
        children: [
          TextField(
            controller: _titleController,
            onChanged: _onTitleChanged,
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
          const SizedBox(height: BrandSpacing.xs),
          Text(
            'Created At: ${DateFormat('MMM dd, yyyy hh:mm a').format(state.note!.createdAt.toLocal())}',
            style: BrandTextStyles.small,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: BrandSpacing.lg),
          if (_controller != null)
            FleatherToolbar.basic(
              controller: _controller!,
              editorKey: _editorKey,
            ),
          Divider(height: 1, thickness: 1, color: BrandColors.subtleGrey),
          Expanded(
            child: _controller == null
                ? const Center(child: CircularProgressIndicator())
                : FleatherEditor(
                    controller: _controller!,
                    focusNode: _focusNode,
                    editorKey: _editorKey,
                    maxContentWidth: 1000,
                    padding: const EdgeInsets.all(BrandSpacing.md),
                  ),
          ),
        ],
      ),
    );
  }
}

/// This is an example insert rule that will insert a new line before and
/// after inline image embed.
class ForceNewlineForInsertsAroundInlineImageRule extends InsertRule {
  @override
  Delta? apply(Delta document, int index, Object data) {
    if (data is! String) return null;

    final iter = DeltaIterator(document);
    final previous = iter.skip(index);
    final target = iter.next();
    final cursorBeforeInlineEmbed = _isInlineImage(target.data);
    final cursorAfterInlineEmbed =
        previous != null && _isInlineImage(previous.data);

    if (cursorBeforeInlineEmbed || cursorAfterInlineEmbed) {
      final delta = Delta()..retain(index);
      if (cursorAfterInlineEmbed && !data.startsWith('\n')) {
        delta.insert('\n');
      }
      delta.insert(data);
      if (cursorBeforeInlineEmbed && !data.endsWith('\n')) {
        delta.insert('\n');
      }
      return delta;
    }
    return null;
  }

  bool _isInlineImage(Object data) {
    if (data is EmbeddableObject) {
      return data.type == 'image' && data.inline;
    }
    if (data is Map) {
      return data[EmbeddableObject.kTypeKey] == 'image' &&
          data[EmbeddableObject.kInlineKey];
    }
    return false;
  }
}
