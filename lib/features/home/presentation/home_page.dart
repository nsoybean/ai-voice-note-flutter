import 'package:ai_voice_note/main.dart';
import 'package:ai_voice_note/test.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

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
      body: Column(
        children: [
          SizedBox(
            height: 40, // Match the height of CustomAppBar
            child: CustomAppBar(
              onToggleSidebar: () {
                setState(() {
                  print('Toggling sidebar');
                  isSidebarExpanded = !isSidebarExpanded;
                });
              },
            ),
          ),
          Expanded(
            child: Row(
              children: [
                /// Sidebar
                Column(
                  children: [
                    Expanded(
                      child: NavigationRail(
                        extended: isSidebarExpanded,
                        useIndicator: true,
                        selectedIndex: selectedIndex,
                        onDestinationSelected: (int index) {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.home),
                            label: Text('Home'),
                            indicatorShape: CircleBorder(),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.folder),
                            label: Text('Folders'),
                          ),
                        ],

                        trailing: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _HoverableProfile(
                            isExpanded: isSidebarExpanded,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // const VerticalDivider(thickness: 1, width: 1),

                /// Main Content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(
                      4,
                    ), // Optional: space around the border
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 0.4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Text(
                              'Main content goes here',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            IconButton(
                              iconSize: 20,
                              icon: const Icon(Icons.http),
                              tooltip: "Test API",
                              onPressed: () async {
                                // call api
                                try {
                                  final response =
                                      await ApiService.fetchExample();
                                  print(
                                    'API Response: \\nStatus: \\${response.statusCode}\\nBody: \\${response.body}',
                                  );
                                } catch (e) {
                                  print('Error calling API: \\${e.toString()}');
                                }
                              },
                            ),
                            IconButton(
                              iconSize: 20,
                              icon: const Icon(Icons.login),
                              tooltip: "Login",
                              onPressed: () async {
                                // call api
                                try {
                                  final response =
                                      await ApiService.fetchExample();
                                  print(
                                    'API Response: \\nStatus: \\${response.statusCode}\\nBody: \\${response.body}',
                                  );
                                } catch (e) {
                                  print('Error calling API: \\${e.toString()}');
                                }
                              },
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

/// hoverable profile
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
        margin: const EdgeInsets.symmetric(horizontal: 0),
        width: widget.isExpanded ? 250 : 60,
        decoration: BoxDecoration(
          color: isHovering ? Colors.grey.shade200 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: PopupMenuButton<String>(
          tooltip: 'User menu',
          offset: const Offset(0, -10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onSelected: (value) {
            if (value == 'settings') {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Settings'),
                  content: const Text('Settings page goes here.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(
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
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircleAvatar(radius: 16, child: Text('S')),
                      SizedBox(width: 8),
                      Text('Shaw Bin', style: TextStyle(fontSize: 12)),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircleAvatar(radius: 16, child: Text('S')),
                      SizedBox(height: 4),
                      Text('Shaw Bin', style: TextStyle(fontSize: 12)),
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

  const CustomAppBar({super.key, required this.onToggleSidebar});

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Container(
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.red, width: 2),
        ),

        // color: Colors.black,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              // margin: const EdgeInsets.only(top: 9), // not working
              child: const WindowButtons(),
            ), // native macOS window controls
            IconButton(
              iconSize: 20,
              icon: const Icon(Icons.menu),
              tooltip: "Toggle Sidebar",
              onPressed: onToggleSidebar,
              // style: ButtonStyle(
              //   minimumSize: MaterialStateProperty.all(const Size(32, 32)),
              //   maximumSize: MaterialStateProperty.all(const Size(32, 32)),
              //   shape: MaterialStateProperty.all(
              //     RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(6),
              //     ),
              //   ),
              //   overlayColor: MaterialStateProperty.resolveWith<Color?>((
              //     states,
              //   ) {
              //     if (states.contains(MaterialState.hovered)) {
              //       return Colors.grey.withOpacity(0.2); // subtle hover color
              //     }
              //     return null;
              //   }),
              //   padding: MaterialStateProperty.all(EdgeInsets.zero),
              //   backgroundColor: MaterialStateProperty.all(Colors.transparent),
              // ),
            ),
            Expanded(child: MoveWindow()), // remaining space on the right
          ],
        ),
      ),
    );
  }
}

/// Custom window buttons (macOS style)
class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70, // Set a fixed width
      decoration: BoxDecoration(
        // color: Colors.lightBlue, // Add a background color
        // border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CloseWindowButton(),
          MinimizeWindowButton(),
          MaximizeWindowButton(),
        ],
      ),
    );
  }
}
