// Redesigned HomePage with AI Voice Note brand kit
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:ai_voice_note/theme/brand_colors.dart';
import 'package:ai_voice_note/test.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSidebarExpanded = true;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.backgroundLight,
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: CustomAppBar(
              onToggleSidebar: () {
                setState(() => isSidebarExpanded = !isSidebarExpanded);
              },
              isAtHomePage: selectedIndex == 0 ? true : false,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: isSidebarExpanded ? 240 : 0,
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
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: AnimatedSize(
                                  duration: const Duration(milliseconds: 250),
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
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Notes',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: BrandColors.textDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: List.generate(
                                    6,
                                    (index) => _VoiceNoteCard(index),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: Container(
        width: widget.isExpanded ? 220 : 56,
        decoration: BoxDecoration(
          color: isHovering ? Colors.grey.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: PopupMenuButton<String>(
          offset: const Offset(0, -10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tooltip: 'User menu',
          onSelected: (value) {
            if (value == 'settings') {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Settings'),
                  content: const Text('Settings page goes here.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
              ),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: widget.isExpanded
                ? Row(
                    children: const [
                      CircleAvatar(radius: 16, child: Text('S')),
                      SizedBox(width: 8),
                      Text('Shaw Bin', style: TextStyle(fontSize: 13)),
                    ],
                  )
                : Column(
                    children: const [
                      CircleAvatar(radius: 16, child: Text('S')),
                      SizedBox(height: 4),
                      Text('SB', style: TextStyle(fontSize: 11)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final VoidCallback onToggleSidebar;
  final bool isAtHomePage;

  const CustomAppBar({
    super.key,
    required this.onToggleSidebar,
    required this.isAtHomePage,
  });

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Row(
        children: [
          const WindowButtons(),
          IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Toggle Sidebar',
            onPressed: onToggleSidebar,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 18),
            tooltip: 'Go Back',
            onPressed: isAtHomePage ? null : () => Navigator.of(context).pop(),
          ),
          Expanded(child: MoveWindow()),
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

Widget _VoiceNoteCard(int index) {
  return SizedBox(
    width: 280,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)), // light gray
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meeting with Product Team',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: BrandColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '“Let’s prioritize onboarding fixes before the new release...”',
            style: TextStyle(
              fontSize: 14,
              color: BrandColors.subtext,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jun 5 · 12:32 PM',
                style: TextStyle(fontSize: 12, color: BrandColors.subtext),
              ),
              Row(
                children: const [
                  Icon(Icons.play_arrow, size: 20, color: BrandColors.primary),
                  SizedBox(width: 8),
                  Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: BrandColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
