import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/cooli_card.dart';
import '../../../core/widgets/info_rows.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/illustrations.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';

class VehicleDetailsScreen extends ConsumerWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      header: BackHeader(
        title: 'Vehicle Information',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          children: [
            // Vehicle Hero Header Card
            CooliCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  VehicleIllustration(type: vehicle.type, size: 90),
                  const SizedBox(height: 14),
                  Text(
                    vehicle.makeModel,
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w900, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.registrationNumber,
                    style: AppTextStyles.captionBold.copyWith(
                      color: AppColors.primaryBlue,
                      fontSize: 15,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StatusBadge.verified(
                        vehicle.verificationState == VehicleVerificationState.verified
                            ? 'Approved on COOLI'
                            : 'Pending Audit',
                      ),
                      if (vehicle.isActive) ...[
                        const SizedBox(width: 8),
                        StatusBadge.online(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Vehicle Technical Details
            CooliCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Technical Details',
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  InfoRow(label: 'Vehicle Category', value: vehicle.typeDisplayName),
                  InfoRow(label: 'Load Capacity', value: vehicle.capacity),
                  InfoRow(label: 'Fuel / Propulsion', value: vehicle.fuelType),
                  InfoRow(label: 'RC Book Reference', value: vehicle.rcNumber),
                  InfoRow(
                    label: 'Insurance Validity',
                    value: DateFormat('dd MMM yyyy').format(vehicle.insuranceExpiry),
                  ),
                  InfoRow(
                    label: 'Fitness Certificate (FC)',
                    value: DateFormat('dd MMM yyyy').format(vehicle.fitnessExpiry),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!vehicle.isActive) ...[
              CooliPrimaryButton(
                label: 'SET AS ACTIVE VEHICLE',
                icon: Icons.check_circle_rounded,
                onPressed: () {
                  ref.read(vehicleNotifierProvider.notifier).setActiveVehicle(vehicle.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${vehicle.makeModel} is now your active vehicle!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.pop();
                },
              ),
              const SizedBox(height: 12),
            ],

            CooliSecondaryButton(
              label: 'UPDATE VEHICLE DOCUMENTS',
              icon: Icons.upload_file_rounded,
              onPressed: () => context.push('/documents'),
            ),
          ],
        ),
      ),
    );
  }
}
