import 'package:ai_voice_note/features/note/application/single_note_controller.dart';
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
    // Use ref.watch to listen for changes and rebuild the widget
    final noteState = ref.watch(noteControllerProvider);

    return noteState.when(
      data: (noteState) {
        final notes = noteState.notes;
        return Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController, // Attach the ScrollController
                padding: const EdgeInsets.only(
                  top: BrandSpacing.md,
                  left: BrandSpacing.xxl,
                  right: BrandSpacing.xxl,
                  bottom: BrandSpacing.xxl, // Add extra bottom padding
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
            if (noteState.isLoadingMore)
              Padding(
                padding: const EdgeInsets.all(BrandSpacing.md),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, // Make the spinner thinner
                  ),
                ),
              ),
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
    spacing: BrandSpacing.xs,
    children: [
      Text(
        label, // label of grouped notes
        style: BrandTextStyles.small,
      ),
      const SizedBox(height: BrandSpacing.xs),
      ...notes.map((note) => _voiceNoteCard(note, ref)),
      const SizedBox(height: BrandSpacing.md),
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
              padding: const EdgeInsets.all(BrandSpacing.sm),
              decoration: BoxDecoration(
                color: isHovering ? BrandColors.subtleGrey : Colors.white,
                borderRadius: BrandRadius.medium,
                boxShadow: [
                  BoxShadow(
                    color: BrandColors.subtleGrey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BrandRadius.medium,
                    ),
                    child: Icon(
                      Icons.insert_drive_file_outlined,
                      color: Colors.blueGrey.shade200,
                    ),
                  ),
                  const SizedBox(width: BrandSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.note.title.isNotEmpty
                              ? widget.note.title
                              : 'Untitled Note',
                          style: BrandTextStyles.small.copyWith(
                            color: BrandColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: BrandSpacing.xs),
                        Text(
                          DateFormat(
                            'hh:mm a',
                          ).format(widget.note.createdAt.toLocal()),
                          style: BrandTextStyles.extraSmall,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        try {
                          await widget.ref
                              .read(singleNoteControllerProvider.notifier)
                              .deleteNoteById(widget.note.id);
                          widget.ref
                              .read(noteControllerProvider.notifier)
                              .fetchNotesGroupedByDate();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete note: $e'),
                            ),
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: const [
                            Icon(Icons.delete, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
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
