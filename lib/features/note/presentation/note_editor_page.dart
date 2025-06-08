import 'package:ai_voice_note/features/home/presentation/home_page.dart';
import 'package:flutter/material.dart';
import 'package:ai_voice_note/theme/brand_text_styles.dart';
import 'package:ai_voice_note/theme/brand_colors.dart';
import 'package:ai_voice_note/theme/brand_radius.dart';
import 'package:ai_voice_note/theme/brand_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_voice_note/features/note/application/note_controller.dart';

class NoteEditorPage extends ConsumerWidget {
  final String noteId;
  final String? title; // Optional title

  const NoteEditorPage({Key? key, required this.noteId, this.title = ''})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              child: ListView(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: (this.title != '')
                          ? title
                          : 'Untitled', // Render title if provided
                      hintStyle: BrandTextStyles.h2.copyWith(
                        color: BrandColors.placeholder,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: BrandTextStyles.h2,
                  ),
                  const SizedBox(height: BrandSpacing.sm),
                  Text('Note ID: $noteId', style: BrandTextStyles.small),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
