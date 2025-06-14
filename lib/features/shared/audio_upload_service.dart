import 'dart:typed_data';
import 'package:ai_voice_note/core/audio_streamer.dart';
import 'package:ai_voice_note/core/http_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class AudioUploadService {
  final HttpClientWrapper httpClient;
  final String backendUrl;

  AudioUploadService({required this.httpClient, required this.backendUrl});

  void listenAudioStreamAndUpload() {
    AudioStreamer.audioStream().listen((bytes) async {
      // log
      print("📁 Received audio chunk: ${bytes.length} bytes");
      // await _sendToBackend(bytes);
    });
  }

  Future<void> _sendToBackend(Uint8List bytes) async {
    try {
      final response = await httpClient.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/octet-stream'},
        body: bytes,
      );

      if (response.statusCode != 200) {
        print('Failed to upload audio chunk: ${response.statusCode}');
      } else {
        print('Audio chunk uploaded successfully');
      }
    } catch (e) {
      print('Error uploading audio chunk: $e');
    }
  }
}

final audioUploadServiceProvider = Provider<AudioUploadService>((ref) {
  final httpClient = HttpClientWrapper(http.Client());
  const backendUrl =
      'http://your-backend-url.com/upload'; // Replace with your backend URL
  return AudioUploadService(httpClient: httpClient, backendUrl: backendUrl);
});
