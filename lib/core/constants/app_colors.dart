import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const primary = Color(0xFF3D2B8F);
  static const primaryLight = Color(0xFF6A52C4);
  static const primaryDark = Color(0xFF271A6B);

  // Accent (coins, rewards, highlights)
  static const accent = Color(0xFFF4A61D);
  static const accentLight = Color(0xFFFFC84A);

  // Backgrounds
  static const background = Color(0xFFF5F0E8); // Parchment
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFEDE8DC);

  // Text
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF5A5A72);
  static const textHint = Color(0xFF9A9AB0);

  // Status
  static const success = Color(0xFF2D9B5D);
  static const error = Color(0xFFD64045);
  static const warning = Color(0xFFF4A61D);

  // Letter tile colors
  static const tileDefault = Color(0xFFE8E0F0);
  static const tileSelected = Color(0xFF3D2B8F);
  static const tileCorrect = Color(0xFF2D9B5D);

  // High contrast mode
  static const hcBackground = Color(0xFF000000);
  static const hcSurface = Color(0xFF1A1A1A);
  static const hcText = Color(0xFFFFFFFF);
  static const hcAccent = Color(0xFFFFFF00); // Yellow — colorblind safe
  static const hcPrimary = Color(0xFF7B6FE8);
}
