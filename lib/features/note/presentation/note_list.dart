import 'package:ai_voice_note/features/note/domain/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_voice_note/theme/brand_colors.dart';
import 'package:ai_voice_note/theme/brand_text_styles.dart';
import 'package:ai_voice_note/theme/brand_spacing.dart';
import 'package:ai_voice_note/theme/brand_radius.dart';
import 'package:ai_voice_note/features/note/application/note_controller.dart';
import 'package:ai_voice_note/features/note/presentation/note_editor_page.dart';
import 'package:intl/intl.dart';

class NoteList extends ConsumerStatefulWidget {
  const NoteList({Key? key}) : super(key: key);

  @override
  ConsumerState<NoteList> createState() => _NoteListState();
}

class _NoteListState extends ConsumerState<NoteList> {
  @override
  void initState() {
    super.initState();
    // Trigger fetchNotesGroupedByDate in initState
    Future.microtask(
      () => ref.read(noteControllerProvider.notifier).fetchNotesGroupedByDate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteState = ref.watch(noteControllerProvider);

    return noteState.when(
      data: (noteState) {
        final notes = noteState.notes;
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: BrandSpacing.md,
                  horizontal: BrandSpacing.xxl,
                ),
                children: notes.entries.map((entry) {
                  final dateKey = entry.key;
                  final date = DateTime.parse(dateKey);
                  final now = DateTime.now();

                  String label;
                  if (date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day) {
                    label = 'Today';
                  } else if (date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day - 1) {
                    label = 'Yesterday';
                  } else {
                    label = DateFormat('yyyy, MMM dd').format(date);
                  }

                  return _buildDateSection(label, entry.value, ref);
                }).toList(),
              ),
            ),
            noteState.hasMoreData
                ? Padding(
                    padding: const EdgeInsets.all(BrandSpacing.md),
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(noteControllerProvider.notifier)
                            .fetchNextPage();
                      },
                      child: const Text('Load More'),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

Widget _buildDateSection(String label, List<Note> notes, WidgetRef ref) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label, // label of grouped notes
        style: BrandTextStyles.small,
      ),
      const SizedBox(height: BrandSpacing.md),
      ...notes.map((note) => _voiceNoteCard(note, ref)).toList(),
      const SizedBox(height: BrandSpacing.lg),
    ],
  );
}

// Replace the `_voiceNoteCard` function with the new `VoiceNoteCard` widget.
Widget _voiceNoteCard(Note note, WidgetRef ref) {
  return VoiceNoteCard(note: note, ref: ref);
}

class VoiceNoteCard extends StatefulWidget {
  final Note note;
  final WidgetRef ref; // Add ref to the constructor

  const VoiceNoteCard({Key? key, required this.note, required this.ref})
    : super(key: key);

  @override
  State<VoiceNoteCard> createState() => _VoiceNoteCardState();
}

class _VoiceNoteCardState extends State<VoiceNoteCard> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditorPage(noteId: widget.note.id),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: BrandSpacing.sm),
          padding: const EdgeInsets.all(BrandSpacing.md),
          decoration: BoxDecoration(
            color: isHovering ? Colors.grey.shade100 : Colors.white,
            borderRadius: BrandRadius.large,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.note.title.isNotEmpty
                    ? widget.note.title
                    : 'Untitled Note',
                style: BrandTextStyles.small.copyWith(
                  fontWeight: FontWeight.w500,
                  color: BrandColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              widget.note.title.isNotEmpty
                  ? const Text(
                      '“Let’s prioritize onboarding flow before Monday. Also check the summary section alignment...”',
                      style: BrandTextStyles.small,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      'No description available.',
                      style: BrandTextStyles.small,
                    ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('hh:mm a').format(widget.note.createdAt),
                    style: BrandTextStyles.extraSmall,
                  ),
                  Row(
                    children: const [
                      Icon(
                        Icons.play_arrow,
                        size: 18,
                        color: BrandColors.primary,
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: BrandColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
