import 'dart:io';
import 'dart:ui';
import 'package:ai_voice_note/features/auth/presentation/auth_home_page.dart';
import 'package:ai_voice_note/theme/brand_colors.dart';
import 'package:ai_voice_note/theme/theme_data.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ProviderScope(child: VoiceNoteApp()));

  doWhenWindowReady(() {
    const initialSize = Size(1050, 700);
    appWindow.minSize = Size(500, 700);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "AI Voice Note";
    appWindow.show();
  });
}

class VoiceNoteApp extends StatelessWidget {
  const VoiceNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Voice Note',
      theme: lightTheme,
      home: const AuthHomePage(),
      // home: const HomePage(),
      // home: const VoiceNoteHome(),
      // home: const ListOfNotesTest(),
    );
  }
}

// home
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

// test audio sake
class RecordAudioTest extends StatefulWidget {
  const RecordAudioTest({super.key});

  @override
  State<RecordAudioTest> createState() => _RecordAudioTestState();
}

class _RecordAudioTestState extends State<RecordAudioTest> {
  bool isRecording = false;
  Process? recordingProcess;
  String? currentRecordingPath;
  List<FileSystemEntity> recordings = [];

  @override
  void initState() {
    super.initState();
    _refreshRecordings();
  }

  String _generateOutputPath() {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '${Directory.systemTemp.path}/recording_$timestamp.wav';
  }

  void _refreshRecordings() {
    final dir = Directory.systemTemp;
    final files =
        dir
            .listSync()
            .where((f) => f is File && f.path.toLowerCase().endsWith('.wav'))
            .toList()
          ..sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
          );

    setState(() => recordings = files);
  }

  void _startRecording() async {
    final helperPath = Utils.resolveHelperPath();
    final outputPath = _generateOutputPath();
    currentRecordingPath = outputPath;

    try {
      final process = await Process.start(helperPath, [
        'start',
        '--output',
        outputPath,
      ]);

      recordingProcess = process;
      setState(() => isRecording = true);

      process.stdout.transform(SystemEncoding().decoder).listen(print);
      process.stderr.transform(SystemEncoding().decoder).listen(print);

      process.exitCode.then((code) {
        print('[helper] Exited with code: $code');
        if (mounted) {
          setState(() => isRecording = false);
          _refreshRecordings();
        }
      });
    } catch (e, stack) {
      print('❌ Failed to start recording: $e');
      print(stack);
      _showErrorDialog(e.toString());
    }
  }

  void _stopRecording() {
    if (recordingProcess != null) {
      print('🛑 Stopping recording...');
      recordingProcess!.kill(ProcessSignal.sigint);
      recordingProcess = null;
    }
  }

  void _deleteRecording(File file) async {
    await file.delete();
    _refreshRecordings();
  }

  void _openInFinder(String path) {
    Process.run('open', [path]);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Voice Note')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: isRecording
                ? ElevatedButton(
                    onPressed: _stopRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Stop Recording'),
                  )
                : ElevatedButton(
                    onPressed: _startRecording,
                    child: const Text('Start Recording'),
                  ),
          ),
          const Divider(),
          const Text(
            'Saved Recordings',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: recordings.length,
              itemBuilder: (context, index) {
                final file = recordings[index] as File;
                final fileName = file.path.split('/').last;
                final modified = file.lastModifiedSync();

                return ListTile(
                  title: Text(fileName),
                  subtitle: Text(modified.toLocal().toString()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        tooltip: 'Play',
                        onPressed: () => _openInFinder(file.path),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete',
                        onPressed: () => _deleteRecording(file),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// test card view sake
class ListOfNotesTest extends StatelessWidget {
  const ListOfNotesTest({super.key});

  @override
  Widget build(BuildContext context) {
    final mockNotes = [
      {
        'title': 'Team meeting summary',
        'date': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'title': 'User feedback notes',
        'date': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'title': 'Weekly marketing ideas',
        'date': DateTime.now().subtract(const Duration(days: 3)),
      },
      {
        'title': 'Podcast thoughts',
        'date': DateTime.now().subtract(const Duration(days: 4)),
      },
      {
        'title': 'Client call notes',
        'date': DateTime.now().subtract(const Duration(days: 5)),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockNotes.length,
        itemBuilder: (context, index) {
          final note = mockNotes[index];
          final title = note['title'] as String;
          final date = note['date'] as DateTime;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(DateFormat('yMMMd • h:mm a').format(date)),
              onTap: () {
                // You can navigate to a detailed note view here
              },
            ),
          );
        },
      ),
    );
  }
}

// utils
class Utils {
  static String resolveHelperPath() {
    if (Platform.isMacOS) {
      final executablePath = File(Platform.resolvedExecutable).parent.path;
      return '$executablePath/../Resources/AudioRecorderHelper';
    }
    throw UnsupportedError('Unsupported platform');
  }
}

/// Simple API service for calling local endpoints
class ApiService {
  static const String baseUrl = 'http://127.0.0.1:3000';

  /// Example GET request
  static Future<http.Response> fetchExample() async {
    final url = Uri.parse('$baseUrl/');
    return await http.get(url);
  }

  // Add more methods for other endpoints as needed
}
