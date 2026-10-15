import 'package:flutter/material.dart';

/// Centralized Spacing and Border Radii constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;

  // Edge Insets Helpers
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(20.0);
  static const EdgeInsets compactPadding = EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);

  // Border Radii
  static const double cardRadiusVal = 20.0;
  static const double inputRadiusVal = 16.0;
  static const double buttonRadiusVal = 16.0;
  static const double chipRadiusVal = 24.0;
  static const double badgeRadiusVal = 8.0;

  static BorderRadius get cardRadius => BorderRadius.circular(cardRadiusVal);
  static BorderRadius get cardRadiusSmall => BorderRadius.circular(14.0);
  static BorderRadius get cardRadiusLarge => BorderRadius.circular(24.0);
  static BorderRadius get inputRadius => BorderRadius.circular(inputRadiusVal);
  static BorderRadius get buttonRadius => BorderRadius.circular(buttonRadiusVal);
  static BorderRadius get chipRadius => BorderRadius.circular(chipRadiusVal);
  static BorderRadius get badgeRadius => BorderRadius.circular(badgeRadiusVal);
  static BorderRadius get topSheetRadius => const BorderRadius.vertical(top: Radius.circular(24.0));
}
