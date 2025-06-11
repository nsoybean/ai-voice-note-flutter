import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'brand_colors.dart';

class BrandTextStyles {
  /// Hero title (40px)
  // static const TextStyle h1 = TextStyle(
  //   fontSize: 40,
  //   fontWeight: FontWeight.w700,
  //   height: 1.2,
  //   color: BrandColors.textDark,
  //   fontFamily: 'Inter',
  // );
  static final TextStyle h1 = GoogleFonts.sora(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: BrandColors.textDark,
  );

  /// Section title (28px)
  // static const TextStyle h2 = TextStyle(
  //   fontSize: 28,
  //   fontWeight: FontWeight.w600,
  //   height: 1.3,
  //   color: BrandColors.textDark,
  //   fontFamily: 'Inter',
  // );
  static final TextStyle h2 = GoogleFonts.sora(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: BrandColors.textDark,
  );

  /// Body text (16px)
  // static const TextStyle body = TextStyle(
  //   fontSize: 16,
  //   fontWeight: FontWeight.w400,
  //   height: 1.5,
  //   color: BrandColors.textDark,
  //   fontFamily: 'Inter',
  // );
  static final TextStyle body = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: BrandColors.textDark,
  );

  /// Small text (14px)
  // static const TextStyle small = TextStyle(
  //   fontSize: 14,
  //   fontWeight: FontWeight.w400,
  //   height: 1.4,
  //   color: BrandColors.subtext,
  //   fontFamily: 'Inter',
  // );
  static final TextStyle small = GoogleFonts.dmSans(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: BrandColors.textDark,
  );

  /// Extra Small text (12px)
  // static const TextStyle extraSmall = TextStyle(
  //   fontSize: 12,
  //   height: 1.4,
  //   color: BrandColors.subtext,
  //   fontFamily: 'Inter',
  // );
  static final TextStyle extraSmall = GoogleFonts.dmSans(
    fontSize: 12,
    height: 1.4,
    color: BrandColors.textDark,
  );

  /// Light mode variants (override if needed)
  static TextStyle h1Light = h1.copyWith(color: BrandColors.textDark);
  static TextStyle h2Light = h2.copyWith(color: BrandColors.textDark);
  static TextStyle bodyLight = body.copyWith(color: BrandColors.textDark);
  static TextStyle smallLight = small.copyWith(color: BrandColors.textDark);

  /// Dark mode variants
  static TextStyle h1Dark = h1.copyWith(color: BrandColors.textLight);
  static TextStyle h2Dark = h2.copyWith(color: BrandColors.textLight);
  static TextStyle bodyDark = body.copyWith(color: BrandColors.textLight);
  static TextStyle smallDark = small.copyWith(color: BrandColors.textLight);
}
