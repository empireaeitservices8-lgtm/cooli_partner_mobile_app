import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../models/vehicle.dart';

/// Clean real-image rendering for different vehicle classes (Mini Truck, Bolero, Heavy Truck, Bike, Auto)
class VehicleIllustration extends StatelessWidget {
  final VehicleType type;
  final double size;
  final Color? color;

  const VehicleIllustration({
    super.key,
    required this.type,
    this.size = 64,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case VehicleType.miniTruck:
        return TruckIllustration(size: size, isMini: true);
      case VehicleType.pickupTruck:
        return TruckIllustration(size: size, isMini: false);
      case VehicleType.heavyTruck:
      case VehicleType.container:
        return HeavyTruckIllustration(size: size);
      case VehicleType.auto:
        return AutoIllustration(size: size);
      case VehicleType.bike:
        return BikeIllustration(size: size);
    }
  }
}

/// Tata Ace / Mini Truck Real Image Illustration
class TruckIllustration extends StatelessWidget {
  final double size;
  final bool isMini;

  const TruckIllustration({
    super.key,
    this.size = 80,
    this.isMini = true,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = isMini ? 'assets/images/mini_truck.jpg' : 'assets/images/pickup_truck.jpg';
    return Container(
      width: size,
      height: size * 0.65,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.15), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.local_shipping_rounded,
              size: size * 0.45,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ),
    );
  }
}

/// Heavy Commercial Truck Real Image Illustration
class HeavyTruckIllustration extends StatelessWidget {
  final double size;

  const HeavyTruckIllustration({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.65,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentOrange.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(
          'assets/images/heavy_truck.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.fire_truck_rounded,
              size: size * 0.45,
              color: AppColors.accentOrangeDark,
            ),
          ),
        ),
      ),
    );
  }
}

/// 3-Wheeler Auto Illustration
class AutoIllustration extends StatelessWidget {
  final double size;

  const AutoIllustration({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.65,
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3), width: 1.2),
      ),
      child: Center(
        child: Icon(
          Icons.electric_rickshaw_rounded,
          size: size * 0.45,
          color: AppColors.success,
        ),
      ),
    );
  }
}

/// Bike / Scooter Illustration
class BikeIllustration extends StatelessWidget {
  final double size;

  const BikeIllustration({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.65,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
      ),
      child: Center(
        child: Icon(
          Icons.two_wheeler_rounded,
          size: size * 0.45,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Real Cargo Image Thumbnail
class RealCargoImage extends StatelessWidget {
  final String materialName;
  final double width;
  final double height;
  final double borderRadius;

  const RealCargoImage({
    super.key,
    required this.materialName,
    this.width = 80,
    this.height = 80,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final isApples = materialName.toLowerCase().contains('apple') ||
        materialName.toLowerCase().contains('fruit') ||
        materialName.toLowerCase().contains('produce');
    final asset = isApples ? 'assets/images/load_apples.jpg' : 'assets/images/load_electronics.jpg';

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.infoLight,
            child: const Icon(Icons.inventory_2_rounded, color: AppColors.primaryBlue),
          ),
        ),
      ),
    );
  }
}
