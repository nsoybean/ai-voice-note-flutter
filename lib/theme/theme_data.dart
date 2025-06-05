import 'package:ai_voice_note/theme/brand_colors.dart';
import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  fontFamily: 'Inter',
  scaffoldBackgroundColor: BrandColors.backgroundLight,
  primaryColor: BrandColors.primary,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: BrandColors.textDark),
  ),
  colorScheme: ColorScheme.light(
    primary: BrandColors.primary,
    secondary: BrandColors.accent,
    background: BrandColors.backgroundLight,
    surface: Colors.white,
  ),
);

final ThemeData darkTheme = ThemeData(
  fontFamily: 'Inter',
  scaffoldBackgroundColor: BrandColors.backgroundDark,
  primaryColor: BrandColors.primary,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: BrandColors.textLight),
  ),
  colorScheme: ColorScheme.dark(
    primary: BrandColors.primary,
    secondary: BrandColors.accent,
    background: BrandColors.backgroundDark,
    surface: BrandColors.darkSurface,
  ),
);
