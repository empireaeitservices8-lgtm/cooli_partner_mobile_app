import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Soft lavender/blue backdrop with subtle aesthetic glow
class SoftBackground extends StatelessWidget {
  final Widget child;

  const SoftBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
      ),
      child: Stack(
        children: [
          // Subtle top-right ambient bubble
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue.withOpacity(0.04),
              ),
            ),
          ),
          // Subtle bottom-left ambient bubble
          Positioned(
            bottom: 40,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryPurple.withOpacity(0.03),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Full Gradient Background for Splash, Onboarding, and Hero cards
class GradientBackground extends StatelessWidget {
  final Widget child;
  final LinearGradient? gradient;

  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.heroGradient,
      ),
      child: child,
    );
  }
}

/// Decorative Wave painter at the top/bottom of login or hero banners
class DecorativeWave extends StatelessWidget {
  final double height;
  final Color color;

  const DecorativeWave({
    super.key,
    this.height = 80,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _WavePainter(color: color),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;

  _WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.25,
      0,
      size.width * 0.5,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.8,
      size.width,
      size.height * 0.3,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Stylized City Silhouette / Logistics skyline backdrop
class CityIllustrationBackground extends StatelessWidget {
  final double height;
  final Color? color;

  const CityIllustrationBackground({
    super.key,
    this.height = 60,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primaryBlue.withOpacity(0.06);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _CityPainter(color: effectiveColor),
      ),
    );
  }
}

class _CityPainter extends CustomPainter {
  final Color color;

  _CityPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    // Buildings silhouette
    double x = 0;
    final heights = [0.4, 0.7, 0.5, 0.85, 0.3, 0.6, 0.9, 0.45, 0.65, 0.35, 0.75, 0.5];
    final w = size.width / heights.length;

    for (int i = 0; i < heights.length; i++) {
      final h = size.height * (1 - heights[i]);
      path.lineTo(x, h);
      path.lineTo(x + w, h);
      x += w;
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
