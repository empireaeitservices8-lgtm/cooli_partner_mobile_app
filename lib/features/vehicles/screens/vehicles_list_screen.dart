import 'package:cooli_partner/models/partner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/cooli_cards_specialized.dart';
import '../../../core/widgets/state_views.dart';
import '../../../providers/providers.dart';

class VehiclesListScreen extends ConsumerWidget {
  const VehiclesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleState = ref.watch(vehicleNotifierProvider);
    final partner = ref.watch(partnerNotifierProvider).partner;
    final vehicles = vehicleState.vehicles;

    String screenTitle;
    String screenSubtitle;
    Color roleColor;

    switch (partner.role) {
      case PartnerRole.rider:
        screenTitle = 'My Cabs & Vehicles';
        screenSubtitle =
            'Registered passenger taxis, cabs, and autos linked to your Rider profile.';
        roleColor = AppColors.primaryBlue;
        break;
      case PartnerRole.porter:
        screenTitle = 'My Mini-Trucks';
        screenSubtitle =
            'Registered Tata Ace and cargo carriers linked to your Porter profile.';
        roleColor = const Color(0xFFD97706);
        break;
      case PartnerRole.truckDriver:
        screenTitle = 'Heavy Freight Trucks';
        screenSubtitle =
            'Registered 16T heavy commercial carrier linked to your Truck Driver profile.';
        roleColor = AppColors.secondaryPurple;
        break;
      case PartnerRole.fleetOwner:
        screenTitle = 'Commercial Fleet (5+ Vehicles)';
        screenSubtitle =
            'Multi-vehicle commercial fleet oversight and driver assignment.';
        roleColor = const Color(0xFF059669);
        break;
    }

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      screenTitle,
                      style: AppTextStyles.headline
                          .copyWith(fontWeight: FontWeight.w900),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'REGISTERED: ${partner.role.title.toUpperCase()}',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: roleColor),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded,
                      color: AppColors.primaryBlue, size: 28),
                  tooltip: 'Add Vehicle',
                  onPressed: () => context.push('/vehicles/add'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              screenSubtitle,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 18),
            if (vehicleState.isLoading)
              const LoadingState(message: 'Loading your registered vehicles...')
            else if (vehicles.isEmpty)
              EmptyState.noVehicles(
                  onAddVehicle: () => context.push('/vehicles/add'))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vehicles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return CooliVehicleCard(
                    vehicle: vehicle,
                    onViewDetails: () {
                      context.push('/vehicles/details', extra: vehicle);
                    },
                    onSetActive: () {
                      ref
                          .read(vehicleNotifierProvider.notifier)
                          .setActiveVehicle(vehicle.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${vehicle.makeModel} set as active commercial vehicle.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  );
                },
              ),
            const SizedBox(height: 24),
            CooliSecondaryButton(
              label: '+ REGISTER NEW VEHICLE',
              icon: Icons.add_rounded,
              onPressed: () => context.push('/vehicles/add'),
            ),
          ],
        ),
      ),
    );
  }
}
