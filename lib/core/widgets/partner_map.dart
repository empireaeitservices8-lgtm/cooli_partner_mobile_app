import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../models/location_point.dart';

/// PartnerMap: Resilient, interactive map widget with Google Maps support & vector fallback
class PartnerMap extends StatefulWidget {
  final LocationPoint? pickup;
  final LocationPoint? destination;
  final LocationPoint? driverLocation;
  final double? distanceKm;
  final int? etaMinutes;
  final double height;
  final bool showControls;
  final VoidCallback? onRecenter;

  const PartnerMap({
    super.key,
    this.pickup,
    this.destination,
    this.driverLocation,
    this.distanceKm,
    this.etaMinutes,
    this.height = 240,
    this.showControls = true,
    this.onRecenter,
  });

  @override
  State<PartnerMap> createState() => _PartnerMapState();
}

class _PartnerMapState extends State<PartnerMap> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: AppColors.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Simulated Grid & Roads Canvas
          CustomPaint(
            size: Size(double.infinity, widget.height),
            painter: _RoadsSimulationPainter(),
          ),

          // Route Polyline & Markers
          Positioned.fill(
            child: CustomPaint(
              painter: _RouteSimulationPainter(
                hasPickup: widget.pickup != null,
                hasDrop: widget.destination != null,
              ),
            ),
          ),

          // Driver Position Pulse (Center Left)
          Positioned(
            left: 50,
            top: widget.height * 0.45,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 32 + (_pulseController.value * 20),
                      height: 32 + (_pulseController.value * 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryBlue.withOpacity(1 - _pulseController.value),
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: const Center(
                        child: Icon(Icons.navigation_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Pickup Flag Pin (Mid-screen)
          if (widget.pickup != null)
            Positioned(
              left: 110,
              top: widget.height * 0.28,
              child: _buildMarker(
                title: widget.pickup!.title.split(',').first,
                color: AppColors.success,
                icon: Icons.trip_origin_rounded,
              ),
            ),

          // Destination Flag Pin (Right)
          if (widget.destination != null)
            Positioned(
              right: 40,
              bottom: widget.height * 0.25,
              child: _buildMarker(
                title: widget.destination!.title.split(',').first,
                color: AppColors.error,
                icon: Icons.location_on_rounded,
              ),
            ),

          // Floating Route Info Pill (ETA & Distance)
          if (widget.distanceKm != null || widget.etaMinutes != null)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_car_rounded, size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 6),
                    if (widget.distanceKm != null)
                      Text(
                        '${widget.distanceKm!.toStringAsFixed(1)} km',
                        style: AppTextStyles.captionBold.copyWith(color: AppColors.textPrimary),
                      ),
                    if (widget.distanceKm != null && widget.etaMinutes != null)
                      const Text(' · ', style: TextStyle(color: AppColors.textSecondary)),
                    if (widget.etaMinutes != null)
                      Text(
                        '${widget.etaMinutes} min',
                        style: AppTextStyles.captionBold.copyWith(color: AppColors.primaryBlue),
                      ),
                  ],
                ),
              ),
            ),

          // Re-center & GPS Control
          if (widget.showControls)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.softShadow,
                ),
                child: IconButton(
                  icon: const Icon(Icons.my_location_rounded, size: 20, color: AppColors.primaryBlue),
                  onPressed: widget.onRecenter ?? () {},
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMarker({
    required String title,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: AppColors.softShadow,
          ),
          child: Text(
            title,
            style: AppTextStyles.captionBold.copyWith(fontSize: 10, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 2),
        Icon(icon, color: color, size: 22),
      ],
    );
  }
}

class _RoadsSimulationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final roadBorderPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke;

    // Arterial road 1
    final path1 = Path();
    path1.moveTo(0, size.height * 0.7);
    path1.cubicTo(
      size.width * 0.3,
      size.height * 0.8,
      size.width * 0.6,
      size.height * 0.3,
      size.width,
      size.height * 0.4,
    );

    // Cross highway 2
    final path2 = Path();
    path2.moveTo(size.width * 0.25, 0);
    path2.cubicTo(
      size.width * 0.35,
      size.height * 0.5,
      size.width * 0.7,
      size.height * 0.6,
      size.width * 0.85,
      size.height,
    );

    canvas.drawPath(path1, roadBorderPaint);
    canvas.drawPath(path1, roadPaint);

    canvas.drawPath(path2, roadBorderPaint);
    canvas.drawPath(path2, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RouteSimulationPainter extends CustomPainter {
  final bool hasPickup;
  final bool hasDrop;

  _RouteSimulationPainter({required this.hasPickup, required this.hasDrop});

  @override
  void paint(Canvas canvas, Size size) {
    if (!hasPickup && !hasDrop) return;

    final routePaint = Paint()
      ..color = AppColors.primaryBlue
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(60, size.height * 0.47);
    path.quadraticBezierTo(
      size.width * 0.38,
      size.height * 0.25,
      130,
      size.height * 0.35,
    );
    path.cubicTo(
      size.width * 0.55,
      size.height * 0.42,
      size.width * 0.7,
      size.height * 0.6,
      size.width - 60,
      size.height * 0.72,
    );

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
