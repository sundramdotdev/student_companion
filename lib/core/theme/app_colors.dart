import 'package:flutter/material.dart';

/// Semantic color tokens not covered by Material's ColorScheme.
/// Use these for status indicators, alerts, and feedback.
class AppColors {
  AppColors._();

  // Status colors — consistent across both themes
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFE0F2FE);

  // Light theme palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF4F46E5);
  static const Color lightSecondary = Color(0xFF7C3AED);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightBorder = Color(0xFFCBD5E1);

  // Dark theme palette
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkDivider = Color(0xFF334155);

  /// Returns status color based on percentage vs threshold.
  static Color attendanceStatus(double percent, double threshold) {
    if (percent >= threshold) return success;
    if (percent >= threshold - 5.0) return warning;
    return danger;
  }

  /// Returns a soft background for the given status color.
  static Color statusBackground(Color statusColor) {
    if (statusColor == success) return successLight;
    if (statusColor == warning) return warningLight;
    if (statusColor == danger) return dangerLight;
    return infoLight;
  }
}
