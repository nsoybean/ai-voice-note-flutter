import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_voice_note/theme/brand_colors.dart';
import 'package:ai_voice_note/theme/brand_text_styles.dart';
import 'package:ai_voice_note/theme/brand_spacing.dart';
import 'package:ai_voice_note/theme/brand_radius.dart';
import 'package:ai_voice_note/features/note/application/note_controller.dart';
import 'package:ai_voice_note/features/note/presentation/note_editor_page.dart';
import 'package:ai_voice_note/features/shared/elements.dart';

class CreateNoteButton extends ConsumerWidget {
  const CreateNoteButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: BrandSpacing.md,
          vertical: BrandSpacing.md,
        ),
        shape: RoundedRectangleBorder(borderRadius: BrandRadius.medium),
        iconColor: BrandColors.backgroundDark,
      ),
      onPressed: () async {
        try {
          final newNote = await ref
              .read(noteControllerProvider.notifier)
              .create();

          if (newNote != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteEditorPage(noteId: newNote.id),
              ),
            );
          } else {
            CustomSnackBar.show(
              context,
              message: 'Failed to create note.',
              backgroundColor: BrandColors.warning,
              textStyle: BrandTextStyles.small,
            );
          }
        } catch (e) {
          CustomSnackBar.show(
            context,
            message: 'An error occurred: $e',
            backgroundColor: BrandColors.warning,
            textStyle: BrandTextStyles.small,
          );
        }
      },
      child: Text(
        'Create Note',
        style: BrandTextStyles.small.copyWith(color: BrandColors.textDark),
      ),
    );
  }
}
