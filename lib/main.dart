import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const VoiceNoteApp());
}

// get path to executable
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
      home: const VoiceNoteHomePage(),
    );
  }
}

class VoiceNoteHomePage extends StatefulWidget {
  const VoiceNoteHomePage({super.key});

  @override
  State<VoiceNoteHomePage> createState() => _VoiceNoteHomePageState();
}

class _VoiceNoteHomePageState extends State<VoiceNoteHomePage> {
  bool isRecording = false;

  void _startNativeHelper() async {
    final helperPath = resolveHelperPath();
    final outputPath = '/tmp/flutter_recording.wav';

    print('🔍 Directory.current: ${Directory.current.path}');
    print('🔍 Checking helper path: $helperPath');
    print('🔍 File exists: ${File(helperPath).existsSync()}');

    try {
      setState(() => isRecording = true);

      final process = await Process.start(helperPath, ['--output', outputPath]);

      print('✅ Process started');

      process.stdout.transform(SystemEncoding().decoder).listen((data) {
        print('[stdout] $data');
      });

      process.stderr.transform(SystemEncoding().decoder).listen((data) {
        print('[stderr] $data');
      });

      final exitCode = await process.exitCode;
      print('[helper] Exited with code: $exitCode');

      setState(() => isRecording = false);
    } catch (e, stack) {
      print('❌ Caught exception: $e');
      print('📄 Stack trace: $stack');

      setState(() => isRecording = false);

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Text('Could not start native helper:\n$e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Voice Note')),
      body: Center(
        child: ElevatedButton(
          onPressed: _startNativeHelper,
          child: Text(isRecording ? 'Recording...' : 'Start Recording'),
        ),
      ),
    );
  }
}
