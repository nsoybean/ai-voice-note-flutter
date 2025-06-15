import 'dart:convert';

import 'package:ai_voice_note/core/audio_streamer.dart';
import 'package:ai_voice_note/core/http_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

final audioUploadServiceProvider = Provider<AudioUploadService>((ref) {
  final httpClient = HttpClientWrapper(http.Client());
  const backendWsUrl = 'http://localhost:3000'; // Replace with your backend URL

  return AudioUploadService(httpClient: httpClient, backendWsUrl: backendWsUrl);
});

class AudioUploadService {
  final HttpClientWrapper httpClient;
  final String backendWsUrl;
  late IO.Socket socket;

  AudioUploadService({required this.httpClient, required this.backendWsUrl}) {
    socket = IO.io(
      backendWsUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          // Use WebSocket transport
          .build(),
    );

    socket.onConnect((_) {
      print("🔗 WebSocket connection established");
    });

    socket.onDisconnect((_) {
      print("❌ WebSocket connection disconnected");
    });

    socket.on('error', (data) {
      print("⚠️ WebSocket error: $data");
    });

    // from server
    socket.on('transcriptAudioResponse', (data) {
      if (data is Map<String, dynamic> && data.containsKey('text')) {
        final String text = data['text'];
        print("📝 Received audio transcript: $text");
      } else {
        print("⚠️ Unexpected data format received: $data");
      }
    });
  }

  void listenAudioStreamAndUpload() {
    AudioStreamer.audioStream().listen((bytes) async {
      // Log the received audio chunk
      print("📁 Received audio chunk: ${bytes.length} bytes");

      // check if socket is ready before emitting
      if (!socket.connected) {
        print("⚠️ WebSocket is not connected. Cannot send audio data.");
        return;
      } else {
        // log
        print("📤 Sending audio data to WebSocket");
        // emit
        socket.emit(
            'transcriptAudio',
            jsonEncode({
              'data': bytes,
            }));
      }
    });
  }

  void startWebSocketConnection() {
    if (!socket.connected) {
      socket.connect();
      print('🔗 WebSocket connection started');
    } else {
      print('⚠️ WebSocket is already connected');
    }
  }

  void stopWebSocketConnection() {
    socket.dispose();
    print('❌ WebSocket connection stopped');
  }
}
