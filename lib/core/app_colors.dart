import 'package:flutter/material.dart';

/// Brand palette used across the whole app.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF4F46E5); // indigo
  static const primaryDarkMode = Color(
    0xFF6366F1,
  ); // slightly lighter for dark bg
  static const secondary = Color(0xFF22C55E); // green = correct
  static const error = Color(0xFFEF4444); // red = wrong
  static const warning = Color(0xFFF59E0B);
  static const streak = Color(0xFFF97316); // fire orange
  static const purple = Color(0xFF8B5CF6);
  static const sky = Color(0xFF0EA5E9);
  static const pink = Color(0xFFEC4899);

  // Light surfaces
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);

  // Dark surfaces
  static const darkBackground = Color(0xFF0B1120);
  static const darkSurface = Color(0xFF1E293B);
  static const darkTextPrimary = Color(0xFFF1F5F9);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkBorder = Color(0xFF334155);

  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const successGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Colors used by the confetti celebration.
  static const confetti = [primary, secondary, warning, pink, sky, purple];
}
