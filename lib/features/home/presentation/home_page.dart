// Redesigned HomePage with AI Voice Note brand kit
import 'package:ai_voice_note/features/auth/presentation/auth_home_page.dart';
import 'package:ai_voice_note/features/auth/shared/auth_storage.dart';
import 'package:ai_voice_note/features/note/presentation/note_list.dart';
import 'package:ai_voice_note/theme/brand_colors.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:ai_voice_note/theme/brand_text_styles.dart';
import 'package:ai_voice_note/theme/brand_spacing.dart';
import 'package:ai_voice_note/features/note/presentation/create_note_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_voice_note/features/note/application/note_controller.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  late WidgetRef ref;
  bool isSidebarExpanded = true;
  int selectedIndex = 0;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // Subscribe to RouteObserver
  //   routeObserver.subscribe(this, ModalRoute.of(context)!);
  // }

  // @override
  // void dispose() {
  //   // Unsubscribe from RouteObserver
  //   routeObserver.unsubscribe(this);
  //   super.dispose();
  // }

  // @override
  // void didPopNext() {
  //   // Called when returning to this page
  //   ref.read(noteControllerProvider.notifier).fetchNotesGroupedByDate();
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        this.ref = ref; // Assign ref to a class-level variable
        return Scaffold(
          backgroundColor: BrandColors.backgroundLight,
          body: Column(
            children: [
              SizedBox(
                height: 40,
                child: ReusableAppBar(
                  onToggleSidebar: () {
                    setState(() => isSidebarExpanded = !isSidebarExpanded);
                  },
                  showToggle: true,
                  showBackIcon: false,
                  rightActions: const [CreateNoteButton()],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      width: isSidebarExpanded ? 200 : 0,
                      child: isSidebarExpanded
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Visibility(
                                      visible: isSidebarExpanded,
                                      child: NavigationRail(
                                        extended:
                                            isSidebarExpanded, // Ensure it collapses when the sidebar is collapsed
                                        selectedIndex: selectedIndex,
                                        useIndicator: true,
                                        indicatorColor: BrandColors.primary,
                                        selectedIconTheme: const IconThemeData(
                                          color: BrandColors.backgroundLight,
                                        ),
                                        onDestinationSelected: (index) {
                                          setState(() => selectedIndex = index);
                                        },
                                        destinations: const [
                                          NavigationRailDestination(
                                            icon: Icon(Icons.home),
                                            label: Text('Home'),
                                          ),
                                          NavigationRailDestination(
                                            icon: Icon(Icons.folder),
                                            label: Text('Folders'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      curve: Curves.easeInOut,
                                      child: _HoverableProfile(
                                        isExpanded: isSidebarExpanded,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : null,
                    ),
                    // Main Content
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: BrandSpacing.xs,
                          ),
                          child: const NoteList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HoverableProfile extends StatefulWidget {
  final bool isExpanded;
  const _HoverableProfile({required this.isExpanded});

  @override
  State<_HoverableProfile> createState() => _HoverableProfileState();
}

class _HoverableProfileState extends State<_HoverableProfile> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = isHovering
        ? BrandColors.subtleGrey
        : Colors.transparent; // light hover

    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: BrandSpacing.sm),
        width: widget.isExpanded ? 220 : 56,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(color: BrandColors.backgroundDark),
        ),
        child: PopupMenuButton<String>(
          offset: const Offset(0, -10),
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tooltip: 'User menu',
          onSelected: (value) {
            if (value == 'settings') {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text('Settings', style: BrandTextStyles.h2),
                  content: Text(
                    'Settings page goes here.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: BrandColors.subtext,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            } else if (value == 'logout') {
              // Handle logout
              AuthStorage().clearUser();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AuthHomePage()),
              );
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings, color: Colors.black),
                title: Text(
                  'Settings',
                  style: BrandTextStyles.small.copyWith(color: Colors.black),
                ),
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text(
                  'Log Out',
                  style: BrandTextStyles.small.copyWith(color: Colors.red),
                ),
              ),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: widget.isExpanded
                ? Row(
                    children: const [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: BrandColors.primary,
                        child: Text('S', style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Shaw Bin',
                        style: TextStyle(
                          fontSize: 13,
                          color: BrandColors.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: const [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: BrandColors.primary,
                        child: Text('S', style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'SB',
                        style: TextStyle(
                          fontSize: 11,
                          color: BrandColors.subtext,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class ReusableAppBar extends StatelessWidget {
  final VoidCallback? onToggleSidebar;
  final bool showToggle;
  final bool showBackIcon;
  final VoidCallback? onBack;
  final VoidCallback? onBackCallback; // New callback for back action
  final List<Widget>? rightActions;

  const ReusableAppBar({
    super.key,
    this.onToggleSidebar,
    this.showToggle = true,
    this.showBackIcon = false,
    this.onBack,
    this.onBackCallback, // Initialize the new callback
    this.rightActions,
  });

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Row(
        children: [
          const WindowButtons(),
          if (showToggle)
            IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Toggle Sidebar',
              onPressed: onToggleSidebar,
            ),
          if (showBackIcon)
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 18),
              tooltip: 'Go Back',
              onPressed: () {
                if (onBackCallback != null) {
                  onBackCallback!(); // Trigger the callback if provided
                }
                if (onBack != null) {
                  onBack!(); // Trigger the default back action
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          Expanded(child: MoveWindow()),
          if (rightActions != null) ...rightActions!,
        ],
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CloseWindowButton(),
          MinimizeWindowButton(),
          MaximizeWindowButton(),
        ],
      ),
    );
  }
}
