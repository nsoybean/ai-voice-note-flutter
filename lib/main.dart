import 'dart:io';
import 'dart:ui';
import 'package:ai_voice_note/features/auth/presentation/auth_home_page.dart';
import 'package:ai_voice_note/theme/theme_data.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ai_voice_note/features/auth/application/auth_controller.dart';
import 'package:ai_voice_note/features/home/presentation/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  await dotenv.load(fileName: '.env.dev');
  runApp(const ProviderScope(child: VoiceNoteApp()));

  doWhenWindowReady(() {
    const initialSize = Size(1020, 780);
    appWindow.minSize = Size(500, 400);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "AI Voice Note";
    appWindow.show();
  });
}

final currentUserProvider = FutureProvider.autoDispose((ref) async {
  final authController = ref.read(
    authControllerProvider,
  ); // read without listening to provider
  return await authController.getCurrentUser();
});

class VoiceNoteApp extends StatelessWidget {
  const VoiceNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      title: 'AI Voice Note',
      theme: lightTheme,
      localizationsDelegates: const [
        AppFlowyEditorLocalizations.delegate,
      ],
      home: Consumer(
        builder: (context, ref, _) {
          final userAsync = ref.watch(currentUserProvider);
          return userAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: \\${e}')),
            data: (user) {
              if (user == null) {
                return const AuthHomePage();
              } else {
                return const HomePage();
              }
            },
          );
        },
      ),
    );
  }
}
