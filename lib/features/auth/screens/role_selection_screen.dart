import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../models/models.dart';
import '../../../services/mock_data.dart';
import '../../../providers/providers.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  PartnerRole _selectedRole = PartnerRole.porter;

  @override
  void initState() {
    super.initState();
    final current = ref.read(partnerNotifierProvider).partner;
    _selectedRole = current.role;
  }

  Partner _getPartnerForRole(PartnerRole role) {
    switch (role) {
      case PartnerRole.rider:
        return MockData.riderPartner;
      case PartnerRole.porter:
        return MockData.porterPartner;
      case PartnerRole.truckDriver:
        return MockData.truckDriverPartner;
      case PartnerRole.fleetOwner:
        return MockData.fleetOwnerPartner;
    }
  }

  void _onConfirmSelection() {
    final chosenPartner = _getPartnerForRole(_selectedRole);

    // 1. Switch active partner in state
    ref.read(partnerNotifierProvider.notifier).switchPartner(chosenPartner);

    // 2. Sync filter for jobs - RESTRICTED EXCLUSIVELY TO REGISTERED TYPE
    final filter = _selectedRole.associatedJobType;
    ref.read(jobsNotifierProvider.notifier).setFilter(filter);

    // 3. Reload vehicles for chosen persona
    ref.read(vehicleNotifierProvider.notifier).loadVehicles(chosenPartner);

    // 4. Navigate to Dashboard
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'COOLI PARTNER',
                        style: AppTextStyles.captionBold.copyWith(
                          color: AppColors.primaryBlue,
                          letterSpacing: 1.2,
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'REGISTERED ROLE',
                          style: AppTextStyles.captionBold.copyWith(
                            color: AppColors.primaryBlue,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select Your Partner Category',
                    style: AppTextStyles.headline.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You will see ONLY the features, jobs, and operations tailored to your selected type:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable List of 4 Simple 2-Line Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildOptionCard(
                    role: PartnerRole.rider,
                    icon: Icons.local_taxi_rounded,
                    accentColor: AppColors.primaryBlue,
                    title: 'Rider',
                    subtitle: 'Passenger Cabs, Taxis & Auto Rides',
                  ),
                  const SizedBox(height: 12),
                  _buildOptionCard(
                    role: PartnerRole.porter,
                    icon: Icons.inventory_2_rounded,
                    accentColor: const Color(0xFFD97706),
                    title: 'Porter',
                    subtitle: 'Mini-Trucks, Intra-City Goods & Shifting',
                  ),
                  const SizedBox(height: 12),
                  _buildOptionCard(
                    role: PartnerRole.truckDriver,
                    icon: Icons.local_shipping_rounded,
                    accentColor: AppColors.secondaryPurple,
                    title: 'Truck Driver',
                    subtitle: 'Heavy Commercial Trucks & Freight Bidding',
                  ),
                  const SizedBox(height: 12),
                  _buildOptionCard(
                    role: PartnerRole.fleetOwner,
                    icon: Icons.domain_rounded,
                    accentColor: const Color(0xFF059669),
                    title: 'Fleet Owner',
                    subtitle: 'Multi-Vehicle Fleet & Driver Management',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Bottom Sticky Confirmation Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CooliPrimaryButton(
                    label: 'ENTER DASHBOARD AS ${_selectedRole.title.toUpperCase()}',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _onConfirmSelection,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required PartnerRole role,
    required IconData icon,
    required Color accentColor,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.cardBorder,
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? accentColor.withOpacity(0.10) : Colors.black.withOpacity(0.02),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? accentColor : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // 2-Line Content (Title + Subtitle)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isSelected ? accentColor : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Radio Indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accentColor : AppColors.textTertiary,
                  width: 2,
                ),
                color: isSelected ? accentColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
