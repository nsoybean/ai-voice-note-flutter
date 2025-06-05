import 'package:flutter/material.dart';
import 'brand_colors.dart';

class BrandTextStyles {
  /// Hero title (40px)
  static const TextStyle h1 = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: BrandColors.textDark,
    fontFamily: 'Inter',
  );

  /// Section title (28px)
  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: BrandColors.textDark,
    fontFamily: 'Inter',
  );

  /// Body text (16px)
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: BrandColors.textDark,
    fontFamily: 'Inter',
  );

  /// Small text (14px)
  static const TextStyle small = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: BrandColors.subtext,
    fontFamily: 'Inter',
  );

  /// Light mode variants (override if needed)
  static TextStyle h1Light = h1.copyWith(color: BrandColors.textDark);
  static TextStyle h2Light = h2.copyWith(color: BrandColors.textDark);
  static TextStyle bodyLight = body.copyWith(color: BrandColors.textDark);
  static TextStyle smallLight = small.copyWith(color: BrandColors.subtext);

  /// Dark mode variants
  static TextStyle h1Dark = h1.copyWith(color: BrandColors.textLight);
  static TextStyle h2Dark = h2.copyWith(color: BrandColors.textLight);
  static TextStyle bodyDark = body.copyWith(color: BrandColors.textLight);
  static TextStyle smallDark = small.copyWith(color: BrandColors.subtext);
}
