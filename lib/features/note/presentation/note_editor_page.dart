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
  @override
  void initState() {
    super.initState();

    // trigger the load when page opens
    Future.microtask(() {
      ref
          .read(singleNoteControllerProvider.notifier)
          .loadNoteById(widget.noteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final singleNoteState = ref.watch(singleNoteControllerProvider);

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

    return ListView(
      children: [
        TextField(
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
        ),
        const SizedBox(height: BrandSpacing.sm),
        Text('Note ID: ${widget.noteId}', style: BrandTextStyles.small),
        const SizedBox(height: BrandSpacing.lg),
        TextField(
          decoration: InputDecoration(
            hintText: 'Start writing here...',
            hintStyle: BrandTextStyles.body.copyWith(
              color: BrandColors.subtext,
            ),
            filled: true,
            fillColor: BrandColors.subtleGrey,
            border: OutlineInputBorder(
              borderRadius: BrandRadius.medium,
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(BrandSpacing.md),
          ),
          maxLines: null,
          keyboardType: TextInputType.multiline,
          style: BrandTextStyles.body,
        ),
      ],
    );
  }
}
