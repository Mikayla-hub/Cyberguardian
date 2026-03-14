import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary palette
  static const Color primarySeed = Color(0xFF1A73E8);
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF8AB4F8);
  static const Color secondary = Color(0xFF00BFA5);
  static const Color secondaryDark = Color(0xFF64FFDA);

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF0F1115);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E2128);

  // Status colors
  static const Color error = Color(0xFFD32F2F);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningDark = Color(0xFFFFB74D);
  static const Color success = Color(0xFF388E3C);
  static const Color successDark = Color(0xFF66BB6A);

  // Risk colors
  static const Color riskSafe = Color(0xFF4CAF50);
  static const Color riskLow = Color(0xFF8BC34A);
  static const Color riskMedium = Color(0xFFFF9800);
  static const Color riskHigh = Color(0xFFFF5722);
  static const Color riskCritical = Color(0xFFD32F2F);

  // Scan-specific
  static const Color scanActive = Color(0xFF1A73E8);
  static const Color scanPulse = Color(0xFF448AFF);

  // Gamification
  static const Color xpGold = Color(0xFFFFD700);
  static const Color badgeBronze = Color(0xFFCD7F32);
  static const Color badgeSilver = Color(0xFFC0C0C0);
  static const Color badgeGold = Color(0xFFFFD700);
  static const Color badgePlatinum = Color(0xFFE5E4E2);
}
