import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/shared/recording_state_provider.dart';

class AudioStreamer {
  static const _method = MethodChannel('audio_streamer');
  static const _events = EventChannel('audio_streamer_events');

  static Future<void> start(WidgetRef ref) async {
    await _method.invokeMethod('start');
    ref.read(recordingStateProvider.notifier).state = true;
  }

  static Future<void> stop(WidgetRef ref) async {
    await _method.invokeMethod('stop');
    ref.read(recordingStateProvider.notifier).state = false;
  }

  static Stream<Uint8List> audioStream() {
    return _events.receiveBroadcastStream().map((event) {
      final bytes = event as Uint8List;
      return bytes;
    });
  }
}
