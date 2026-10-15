import 'package:flutter/material.dart';

/// Responsive design utility providing breakpoints and adaptive measurements
class Responsive {
  /// Extra small phones (iPhone SE 1st gen, older Androids < 360px)
  static bool isSmallMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  /// Standard mobile (< 700px)
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 700;

  /// Tablets, iPads, and foldable displays in portrait (700px - 1100px)
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 700 &&
      MediaQuery.of(context).size.width < 1100;

  /// Large desktops and web displays (>= 1100px)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  /// Max width constraint for content readability on tablets and desktops
  static const double maxContentWidth = 640.0;

  /// Dynamic horizontal padding based on screen size
  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 12.0;
    if (width < 700) return 16.0;
    return 24.0;
  }

  /// Adaptable grid column count for card grids
  static int gridColumns(BuildContext context, {int mobileCount = 2, int tabletCount = 4}) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 700) return tabletCount;
    return mobileCount;
  }
}

/// A responsive wrapper widget that centers content and limits max width on wide screens
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = Responsive.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}
