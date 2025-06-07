import 'package:ai_voice_note/features/home/presentation/home_page.dart';
import 'package:flutter/material.dart';
import 'package:ai_voice_note/theme/brand_text_styles.dart';
import 'package:ai_voice_note/theme/brand_colors.dart';
import 'package:ai_voice_note/theme/brand_radius.dart';
import 'package:ai_voice_note/theme/brand_spacing.dart';

class NoteEditorPage extends StatelessWidget {
  final String noteId;

  const NoteEditorPage({Key? key, required this.noteId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.backgroundLight,
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: ReusableAppBar(showToggle: false, showBackIcon: true),
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
                  Text('Editing Note', style: BrandTextStyles.h2),
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
