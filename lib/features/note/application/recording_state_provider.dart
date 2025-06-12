import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecordingStateNotifier extends StateNotifier<bool> {
  RecordingStateNotifier() : super(false);

  void initState() {
    state = true; // Initialize the recording state to false
  }

  void startRecording() {
    state = true;
  }

  void stopRecording() {
    state = false;
  }
}

final recordingStateProvider =
    StateNotifierProvider<RecordingStateNotifier, bool>((ref) {
  return RecordingStateNotifier();
});
