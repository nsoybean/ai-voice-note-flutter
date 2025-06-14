import 'package:flutter/material.dart';

class BrandColors {
  // 🎨 Primary Palette
  static const Color primary = Color(0xFF4A6CF7); // Deep blue-violet
  static const Color accent = Color(0xFFFEC260); // Golden amber
  static const Color backgroundLight = Color(0xFFF9FAFB); // Light greyish white
  static const Color backgroundDark = Color(0xFF111827); // Near-black
  static const Color subtext = Color(
    0xFF6B7280,
  ); // Cool grey for secondary text
  static const Color subtleGrey = Color(
    0xFFF3F4F6,
  ); // Cool grey for secondary text

  // 📝 Text Colors
  static const Color textDark = Color(
    0xFF111827,
  ); // Default text for light mode
  static const Color textLight = Colors.white; // Text for dark mode
  static const Color textPrimary = textDark; // Use existing textDark for primary text
  static const Color menuText = textDark; // Use existing textDark for menu text
  static const Color headingText = textDark; // Use existing textDark for heading text

  // 🌙 Optional Dark Theme Shades
  static const Color darkSurface = Color(
    0xFF1F2937,
  ); // Dark surface for cards/panels

  // ✅ Status Colors
  static const Color success = Color(0xFFD1FAE5); // Light pastel green
  static const Color warning = Color(0xFFFFF7CD); // Light pastel yellow
  static const Color error = Color(0xFFFECACA); // Light pastel red

  // Additional Colors for Editor
  static const Color selection = Color(0xFFCCE7FF); // Light blue for selection
  static const Color codeText = Color(0xFF4A5568); // Dark grey for code text

  // Placeholder Color
  static const Color placeholder = Color(
    0xFF9CA3AF,
  ); // Cool grey for placeholder text

  // Highlight Color
  static const Color highlight = Color(0xFFFFE066); // Light yellow for highlights
}
