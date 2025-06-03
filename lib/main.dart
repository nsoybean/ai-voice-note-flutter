import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const VoiceNoteApp());
}

String resolveHelperPath() {
  if (Platform.isMacOS) {
    final executablePath = File(Platform.resolvedExecutable).parent.path;
    return '$executablePath/../Resources/AudioRecorderHelper';
  }
  throw UnsupportedError('Unsupported platform');
}

class VoiceNoteApp extends StatelessWidget {
  const VoiceNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Voice Note',
      theme: ThemeData.light(),
      home: const VoiceNoteHome(),
    );
  }
}

class VoiceNoteHome extends StatefulWidget {
  const VoiceNoteHome({super.key});

  @override
  State<VoiceNoteHome> createState() => _VoiceNoteHomeState();
}

class _VoiceNoteHomeState extends State<VoiceNoteHome> {
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
    final helperPath = resolveHelperPath();
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
