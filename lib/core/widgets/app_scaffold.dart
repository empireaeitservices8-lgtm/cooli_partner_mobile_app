import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'backgrounds.dart';

/// Universal App Scaffold with consistent background treatment, responsive constraints, and system padding
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool useSoftBackground;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final Color? backgroundColor;
  final Widget? header;
  final double maxContentWidth;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.useSoftBackground = true,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.backgroundColor,
    this.header,
    this.maxContentWidth = Responsive.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    if (header != null) {
      content = Column(
        children: [
          header!,
          Expanded(child: content),
        ],
      );
    }

    content = SafeArea(
      top: safeAreaTop,
      bottom: safeAreaBottom,
      child: content,
    );

    if (useSoftBackground) {
      content = SoftBackground(child: content);
    }

    // Responsive design wrapping for tablets, desktop, and large screens
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > maxContentWidth) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: content,
          ),
        ),
      );
    }

    Widget? responsiveBottomNav = bottomNavigationBar;
    if (responsiveBottomNav != null && screenWidth > maxContentWidth) {
      responsiveBottomNav = Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: responsiveBottomNav,
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: appBar,
      body: content,
      bottomNavigationBar: responsiveBottomNav,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      extendBody: bottomNavigationBar != null,
    );
  }
}
