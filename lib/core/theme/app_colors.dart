import 'package:flutter/material.dart';

/// Centralized color palette for COOLI PARTNER
/// Royal/cobalt blue, modern logistics accents, clean light background
class AppColors {
  // Brand Primary & Accents
  static const Color primaryBlue = Color(0xFF2563EB); // Royal / Cobalt Blue
  static const Color darkBlue = Color(0xFF1D4ED8); // Deep Cobalt
  static const Color lightBlue = Color(0xFF3B82F6); // Electric Blue
  static const Color secondaryPurple = Color(0xFF6366F1); // Indigo / Purple
  static const Color accentOrange = Color(0xFFF59E0B); // Amber / Orange Accent
  static const Color accentOrangeDark = Color(0xFFD97706);
  static const Color primaryYellow = Color(0xFFF59E0B); // Amber Accent Yellow

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF5F8FF); // Very light blue / lavender
  static const Color surface = Color(0xFFFFFFFF); // Pure White Cards
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Light Gray/Slate
  static const Color cardBorder = Color(0xFFE2E8F0); // Subtle Border
  static const Color cardBorderLight = Color(0xFFEFF4FB);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF0F172A); // Dark Navy Text
  static const Color textSecondary = Color(0xFF64748B); // Muted Blue-Gray Text
  static const Color textTertiary = Color(0xFF94A3B8); // Subtle Gray
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status & Feedback
  static const Color success = Color(0xFF16A34A); // Emerald Green
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B); // Warning Amber
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626); // Crimson Red
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0284C7); // Sky Blue Info
  static const Color infoLight = Color(0xFFE0F2FE);

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, darkBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softBlueGradient = LinearGradient(
    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadows
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF1E293B).withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: primaryBlue.withOpacity(0.28),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];
}
