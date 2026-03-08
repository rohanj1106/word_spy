import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get poppinsTheme => GoogleFonts.poppinsTextTheme();

  static TextStyle display({Color? color, bool bold = true}) =>
      GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        color: color,
      );

  static TextStyle heading({Color? color}) => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle subheading({Color? color}) => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle body({Color? color}) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle caption({Color? color}) => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle letterTile({Color? color, double fontSize = 20}) =>
      GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1.2,
      );

  // OpenDyslexic variants — loaded from assets in Phase 3
  // For now, fall back to a more readable sans-serif
  static TextStyle dyslexicBody({Color? color}) => TextStyle(
        fontFamily: 'OpenDyslexic',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
      );
}
