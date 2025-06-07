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
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Initialize the ScrollController
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Trigger fetchNotesGroupedByDate in initState
    Future.microtask(
      () => ref.read(noteControllerProvider.notifier).fetchNotesGroupedByDate(),
    );
  }

  @override
  void dispose() {
    // Dispose the ScrollController
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final noteState = ref.read(noteControllerProvider);
    noteState.when(
      data: (noteState) {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50) {
          if (!noteState.isLoadingMore && noteState.hasMoreData) {
            ref.read(noteControllerProvider.notifier).fetchNextPage();
          }
        }
      },
      loading: () {},
      error: (error, stack) {},
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
                controller: _scrollController, // Attach the ScrollController
                padding: const EdgeInsets.symmetric(
                  vertical: BrandSpacing.md,
                  horizontal: BrandSpacing.xxl,
                ),
                children: notes.entries.map((entry) {
                  final dateKey = entry.key;
                  // Convert dateKey to local time
                  final date = DateTime.parse(dateKey);
                  // Ensure now is in local time
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
            noteState.isLoadingMore
                ? Padding(
                    padding: const EdgeInsets.all(BrandSpacing.md),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, // Make the spinner thinner
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        );
      },
      loading: () => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2, // Make the spinner thinner
          ),
        ),
      ),
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
      ...notes.map((note) => _voiceNoteCard(note, ref)),
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
  bool showMenu = false;

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2), // subtle overlay
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BrandRadius.medium),
          backgroundColor: BrandColors.backgroundLight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
            ), // Limit dialog width
            child: Padding(
              padding: const EdgeInsets.all(BrandSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delete Note', style: BrandTextStyles.body),
                  const SizedBox(height: BrandSpacing.sm),
                  Text(
                    'Are you sure you want to delete this note?',
                    style: BrandTextStyles.body.copyWith(
                      color: BrandColors.subtext,
                    ),
                  ),
                  const SizedBox(height: BrandSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: BrandSpacing.md,
                          ),
                          foregroundColor: BrandColors.subtext,
                          textStyle: BrandTextStyles.body,
                          alignment: Alignment.center,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: BrandSpacing.sm),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BrandColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BrandRadius.medium,
                          ),
                          minimumSize: const Size(
                            96,
                            BrandSpacing.buttonHeight,
                          ),
                          textStyle: BrandTextStyles.body.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          // Add delete logic here
                          setState(() {
                            showMenu = false;
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() {
        isHovering = false;
        showMenu = false;
      }),
      child: Stack(
        children: [
          GestureDetector(
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
                        DateFormat(
                          'hh:mm a',
                        ).format(widget.note.createdAt.toLocal()),
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
          if (isHovering)
            Positioned(
              top: BrandSpacing.sm,
              right: BrandSpacing.sm,
              child: GestureDetector(
                onTap: () => setState(() => showMenu = !showMenu),
                child: const Icon(
                  Icons.more_vert,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ),
          if (showMenu)
            Positioned(
              top: 30,
              right: 8,
              child: Material(
                elevation: 2,
                borderRadius: BrandRadius.medium,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BrandRadius.medium,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() => showMenu = false);
                          _showDeleteConfirmationDialog(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
