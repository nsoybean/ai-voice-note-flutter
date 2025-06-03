import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const VoiceNoteApp());
}

// Resolves path to native Swift executable
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
  final outputPath = '${Directory.systemTemp.path}/flutter_recording.wav';

  void _startRecording() async {
    final helperPath = resolveHelperPath();

    print('🔍 Starting recording...');
    print('🔍 Executable path: $helperPath');
    print('🔍 Recording output path: $outputPath');

    try {
      final process = await Process.start(helperPath, [
        'start',
        '--output',
        outputPath,
      ]);

      recordingProcess = process;
      setState(() => isRecording = true);

      process.stdout.transform(SystemEncoding().decoder).listen((data) {
        print('[stdout] $data');
      });

      process.stderr.transform(SystemEncoding().decoder).listen((data) {
        print('[stderr] $data');
      });

      process.exitCode.then((code) {
        print('[helper] Exited with code: $code');
        if (mounted) setState(() => isRecording = false);
      });
    } catch (e, stack) {
      print('❌ Failed to start recording: $e');
      print('📄 $stack');
      _showErrorDialog(e.toString());
    }
  }

  void _stopRecording() {
    if (recordingProcess != null) {
      print('🛑 Stopping recording...');
      recordingProcess!.kill(ProcessSignal.sigint); // Gracefully stop
      recordingProcess = null;
    }
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
      body: Center(
        child: isRecording
            ? ElevatedButton(
                onPressed: _stopRecording,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Stop Recording'),
              )
            : ElevatedButton(
                onPressed: _startRecording,
                child: const Text('Start Recording'),
              ),
      ),
    );
  }
}
