import 'package:flutter/material.dart';
import 'app_theme.dart';

export 'app_colors.dart';
export 'app_text_styles.dart';
export 'app_spacing.dart';
export 'app_theme.dart';

/// Legacy alias providing backward-compatible access to AppTheme
class CooliPartnerTheme {
  static const Color primaryBlue = AppColors.primaryBlue;
  static const Color darkBlue = AppColors.darkBlue;
  static const Color accentAmber = AppColors.accentOrange;
  static const Color accentOrange = AppColors.accentOrangeDark;
  static const Color emergencyRed = AppColors.error;
  static const Color successGreen = AppColors.success;

  static const Color backgroundLight = AppColors.background;
  static const Color surfaceLight = AppColors.surface;
  static const Color borderLight = AppColors.cardBorder;
  static const Color textDark = AppColors.textPrimary;

  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  static const Color textLight = Color(0xFFF8FAFC);

  static ThemeData get lightTheme => AppTheme.lightTheme;
  static ThemeData get darkTheme => AppTheme.darkTheme;
}
