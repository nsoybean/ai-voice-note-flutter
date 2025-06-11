import 'package:ai_voice_note/theme/brand_colors.dart';
import 'package:ai_voice_note/theme/brand_text_styles.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DesktopEditor extends StatefulWidget {
  const DesktopEditor({
    super.key,
    required this.editorState,
    this.textDirection = TextDirection.ltr,
  });

  final EditorState editorState;
  final TextDirection textDirection;

  @override
  State<DesktopEditor> createState() => _DesktopEditorState();
}

class _DesktopEditorState extends State<DesktopEditor> {
  EditorState get editorState => widget.editorState;

  late final EditorScrollController editorScrollController;

  late EditorStyle editorStyle;
  late Map<String, BlockComponentBuilder> blockComponentBuilders;
  late List<CommandShortcutEvent> commandShortcuts;

  @override
  void initState() {
    super.initState();

    editorScrollController = EditorScrollController(
      editorState: editorState,
      shrinkWrap: false,
    );

    editorStyle = _buildDesktopEditorStyle();
    blockComponentBuilders = _buildBlockComponentBuilders();
    commandShortcuts = _buildCommandShortcuts();
  }

  @override
  void dispose() {
    editorScrollController.dispose();
    editorState.dispose();

    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();

    editorStyle = _buildDesktopEditorStyle();
    blockComponentBuilders = _buildBlockComponentBuilders();
    commandShortcuts = _buildCommandShortcuts();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingToolbar(
      items: [
        paragraphItem,
        ...headingItems,
        ...markdownFormatItems,
        quoteItem,
        bulletedListItem,
        numberedListItem,
        buildTextColorItem(),
        buildHighlightColorItem(),
        ...alignmentItems,
      ],
      tooltipBuilder: (context, _, message, child) {
        return Tooltip(
          message: message,
          preferBelow: false,
          child: child,
        );
      },
      editorState: editorState,
      textDirection: widget.textDirection,
      editorScrollController: editorScrollController,
      child: Directionality(
        textDirection: widget.textDirection,
        child: AppFlowyEditor(
          autoFocus: true,
          editorState: editorState,
          editorScrollController: editorScrollController,
          blockComponentBuilders: blockComponentBuilders,
          commandShortcutEvents: commandShortcuts,
          editorStyle: editorStyle,
          enableAutoComplete: true,
          autoCompleteTextProvider: _buildAutoCompleteTextProvider,
          dropTargetStyle: AppFlowyDropTargetStyle(
              color: BrandColors.primary.withOpacity(0.5)),
          // commented out
          // header: Padding(
          //   padding: const EdgeInsets.only(bottom: 10.0),
          //   child: Image.asset(
          //     'assets/images/header.png',
          //     fit: BoxFit.fitWidth,
          //     height: 150,
          //   ),
          // ),
          footer: _buildFooter(),
        ),
      ),
    );
  }

  // showcase 1: customize the editor style.
  EditorStyle _buildDesktopEditorStyle() {
    return EditorStyle.desktop(
      cursorWidth: 2.0,
      cursorColor: Colors.black,
      selectionColor: Colors.blue.shade100,
      textStyleConfiguration: TextStyleConfiguration(
          text: BrandTextStyles.body,
          href: TextStyle(
              color: BrandColors.primary,
              decoration: TextDecoration.underline,
              backgroundColor: Colors.transparent),
          code: GoogleFonts.robotoMono(
            textStyle: TextStyle(
                fontSize: BrandTextStyles.body.fontSize,
                fontWeight: FontWeight.normal,
                color: Colors.red,
                backgroundColor: BrandColors.subtleGrey),
          ),
          bold: BrandTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      textSpanOverlayBuilder: _buildTextSpanOverlay,
    );
  }

  List<Widget> _buildTextSpanOverlay(
    BuildContext context,
    Node node,
    SelectableMixin delegate,
  ) {
    final delta = node.delta;
    if (delta == null) {
      return [];
    }
    final widgets = <Widget>[];
    final textInserts = delta.whereType<TextInsert>();
    int index = 0;
    for (final textInsert in textInserts) {
      final rects = delegate.getRectsInSelection(
        Selection(
          start: Position(path: node.path, offset: index),
          end: Position(
            path: node.path,
            offset: index + textInsert.length,
          ),
        ),
      );
      // Add a hover menu to the linked text.
      if (rects.isNotEmpty && textInsert.attributes?.href != null) {
        widgets.add(
          Positioned(
            left: rects.first.left,
            top: rects.first.top,
            child: HoverMenu(
              child: Container(
                color: Colors.red.withValues(alpha: 0.5),
                width: rects.first.width,
                height: rects.first.height,
              ),
              itemBuilder: (context) => Material(
                color: Colors.red,
                child: SizedBox(
                  width: 200,
                  height: 48,
                  child: Text(
                    'This is a hover menu:\n${textInsert.attributes?.href}',
                  ),
                ),
              ),
            ),
          ),
        );
      }
      index += textInsert.length;
    }
    return widgets;
  }

  // showcase 2: customize the block style
  Map<String, BlockComponentBuilder> _buildBlockComponentBuilders() {
    final map = {
      ...standardBlockComponentBuilderMap,

      // columns block
      ColumnBlockKeys.type: ColumnBlockComponentBuilder(),
      ColumnsBlockKeys.type: ColumnsBlockComponentBuilder(),
    };

    // show placeholder in focused empty block
    map[ParagraphBlockKeys.type] = ParagraphBlockComponentBuilder(
        showPlaceholder: (editorState, node) {
          final selection = editorState.selection;
          final delta = node.delta;

          // Check if the node is blank and the cursor is within it
          if (delta != null && delta.isEmpty && selection != null) {
            return selection.start.path.equals(node.path);
          }

          return false;
        },
        configuration: BlockComponentConfiguration(
            placeholderText: (_) => 'Start writing here, ‘/’ for commands…',
            placeholderTextStyle: (node, {textSpan}) =>
                BrandTextStyles.body.copyWith(color: BrandColors.placeholder)));

    // customize the image block component to show a menu
    map[ImageBlockKeys.type] = ImageBlockComponentBuilder(
      showMenu: true,
      menuBuilder: (node, _) {
        return const Positioned(
          right: 10,
          child: Text('⭐️ Here is a menu!'),
        );
      },
    );

    // customize the heading block component
    final levelToFontSize = [
      24.0,
      22.0,
      18.0,
      16.0,
      14.0,
    ];
    map[HeadingBlockKeys.type] = HeadingBlockComponentBuilder(
      textStyleBuilder: (level) => BrandTextStyles.h1.copyWith(
        fontSize: levelToFontSize.elementAtOrNull(level - 1) ?? 14.0,
        fontWeight: FontWeight.w600,
      ),
    );

    // customize the padding
    map.forEach((key, value) {
      value.configuration = value.configuration.copyWith(
        padding: (node) {
          if (node.type == ColumnsBlockKeys.type ||
              node.type == ColumnBlockKeys.type) {
            return EdgeInsets.zero;
          }
          return const EdgeInsets.symmetric(vertical: 2.0);
        },
        blockSelectionAreaMargin: (_) =>
            const EdgeInsets.symmetric(vertical: 1.0),
      );

      // disable reordering for now
      // if (key != PageBlockKeys.type) {
      //   value.showActions = (_) => true;
      //   value.actionBuilder = (context, actionState) {
      //     return DragToReorderAction(
      //       blockComponentContext: context,
      //       builder: value,
      //     );
      //   };
      // }
    });
    return map;
  }

  // showcase 3: customize the command shortcuts
  // eg. cmd + f
  List<CommandShortcutEvent> _buildCommandShortcuts() {
    return [
      // customize the highlight color
      customToggleHighlightCommand(
        style: ToggleColorsStyle(
          highlightColor: Colors.orange.shade700,
        ),
      ),
      ...[
        ...standardCommandShortcutEvents
          ..removeWhere(
            (el) =>
                el == toggleHighlightCommand ||
                // remove hyperlinks for now
                el == showLinkMenuCommand ||
                el == openInlineLinkCommand ||
                el == openLinksCommand,
          ),
      ],
      ...findAndReplaceCommands(
        context: context,
        localizations: FindReplaceLocalizations(
          find: 'Find',
          previousMatch: 'Previous match',
          nextMatch: 'Next match',
          close: 'Close',
          replace: 'Replace',
          replaceAll: 'Replace all',
          noResult: 'No result',
        ),
      ),
    ];
  }

  Widget _buildFooter() {
    return SizedBox(
      height: 100,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          // check if the document is empty, if so, add a new paragraph block.
          if (editorState.document.root.children.isEmpty) {
            final transaction = editorState.transaction;
            transaction.insertNode(
              [0],
              paragraphNode(),
            );
            await editorState.apply(transaction);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              editorState.selection = Selection.collapsed(
                Position(path: [0]),
              );
            });
          }
        },
      ),
    );
  }

  String? _buildAutoCompleteTextProvider(
    BuildContext context,
    Node node,
    TextSpan? textSpan,
  ) {
    final editorState = context.read<EditorState>();
    final selection = editorState.selection;
    final delta = node.delta;
    if (selection == null ||
        delta == null ||
        !selection.isCollapsed ||
        selection.endIndex != delta.length ||
        !node.path.equals(selection.start.path)) {
      return null;
    }
    final text = delta.toPlainText();
    // An example, if the text ends with 'hello', then show the autocomplete.
    if (text.endsWith('hello')) {
      return ' world';
    }
    return null;
  }
}

class HoverMenu extends StatefulWidget {
  final Widget child;
  final WidgetBuilder itemBuilder;

  const HoverMenu({
    super.key,
    required this.child,
    required this.itemBuilder,
  });

  @override
  HoverMenuState createState() => HoverMenuState();
}

class HoverMenuState extends State<HoverMenu> {
  OverlayEntry? overlayEntry;

  bool canCancelHover = true;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (details) {
        overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(overlayEntry!);
      },
      onExit: (details) {
        // delay the removal of the overlay entry to avoid flickering.
        Future.delayed(const Duration(milliseconds: 100), () {
          if (canCancelHover) {
            overlayEntry?.remove();
          }
        });
      },
      child: widget.child,
    );
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        child: MouseRegion(
          cursor: SystemMouseCursors.text,
          hitTestBehavior: HitTestBehavior.opaque,
          onEnter: (details) {
            canCancelHover = false;
          },
          onExit: (details) {
            canCancelHover = true;
          },
          child: widget.itemBuilder(context),
        ),
      ),
    );
  }
}
