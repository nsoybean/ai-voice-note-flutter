import 'package:ai_voice_note/features/auth/application/auth_controller.dart';
import 'package:ai_voice_note/main.dart';
import 'package:ai_voice_note/theme/brand_colors.dart';
import 'package:ai_voice_note/theme/brand_radius.dart';
import 'package:ai_voice_note/theme/brand_spacing.dart';
import 'package:ai_voice_note/theme/brand_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth home page
class AuthHomePage extends ConsumerStatefulWidget {
  const AuthHomePage({super.key});

  @override
  ConsumerState<AuthHomePage> createState() => _AuthHomePageState();
}

class _AuthHomePageState extends ConsumerState<AuthHomePage> {
  bool agreedToTerms = false;
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            const Text('🧠', style: BrandTextStyles.h1),
            const SizedBox(height: 24),

            // Headline
            const Text(
              'Your AI Meeting Memory',
              style: BrandTextStyles.h2,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Subheadline
            Text(
              'Record voice, get transcripts, ask questions,\nturn conversations into clear actions—instantly.',
              textAlign: TextAlign.center,
              style: BrandTextStyles.body.copyWith(color: BrandColors.subtext),
            ),

            const SizedBox(height: 32),

            // Sign-in button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: BrandColors.backgroundDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: BrandSpacing.lg,
                  vertical: BrandSpacing.md,
                ),
                shape: RoundedRectangleBorder(borderRadius: BrandRadius.medium),
              ),
              icon: const Icon(Icons.login, size: 20),
              label: const Text("Sign in with Google"),
              onPressed: agreedToTerms
                  ? () async {
                      print('Clicky click');
                      final user = await ref
                          .read(authControllerProvider)
                          .signInWithGoogle();

                      if (user != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomePage()),
                        );
                      }
                    }
                  : null,
            ),

            const SizedBox(height: 16),

            // Terms Checkbox
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: agreedToTerms,
                  onChanged: (value) {
                    setState(() {
                      agreedToTerms = value!;
                    });
                  },
                  checkColor: Colors.white,
                  activeColor: BrandColors.primary,
                ),
                const Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    style: BrandTextStyles.small,
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(color: BrandColors.primary),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(color: BrandColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
