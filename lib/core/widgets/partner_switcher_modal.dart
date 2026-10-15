import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../models/models.dart';
import '../../services/mock_data.dart';
import '../../providers/providers.dart';

/// Modal bottom sheet allowing instantaneous switching between all 4 supported partner personas
void showPartnerSwitcherModal(BuildContext context, WidgetRef ref) {
  final currentPartner = ref.read(partnerNotifierProvider).partner;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title and Explanatory Tagline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Switch Partner Persona',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '4 distinct user types use COOLI PARTNER app',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '4 USERS IN 1 APP',
                      style: AppTextStyles.captionBold.copyWith(
                        color: AppColors.primaryBlue,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // The 4 Partner Personas List
              ...MockData.allDemoPartners.map((partner) {
                final isCurrent = currentPartner.id == partner.id;

                IconData roleIcon;
                Color roleColor;
                switch (partner.role) {
                  case PartnerRole.rider:
                    roleIcon = Icons.local_taxi_rounded;
                    roleColor = AppColors.primaryBlue;
                    break;
                  case PartnerRole.porter:
                    roleIcon = Icons.inventory_2_rounded;
                    roleColor = const Color(0xFFD97706);
                    break;
                  case PartnerRole.truckDriver:
                    roleIcon = Icons.local_shipping_rounded;
                    roleColor = AppColors.secondaryPurple;
                    break;
                  case PartnerRole.fleetOwner:
                    roleIcon = Icons.domain_rounded;
                    roleColor = const Color(0xFF059669);
                    break;
                }

                return GestureDetector(
                  onTap: () {
                    // 1. Switch partner
                    ref.read(partnerNotifierProvider.notifier).switchPartner(partner);

                    // 2. Sync job filter (restricted exclusively to registered type)
                    final filter = partner.role.associatedJobType;
                    ref.read(jobsNotifierProvider.notifier).setFilter(filter);

                    // 3. Sync vehicles for this registered persona
                    ref.read(vehicleNotifierProvider.notifier).loadVehicles(partner);

                    Navigator.of(ctx).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(roleIcon, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Switched to ${partner.name} (${partner.role.title}) mode',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: roleColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isCurrent ? roleColor.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isCurrent ? roleColor : AppColors.cardBorder,
                        width: isCurrent ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar / Role badge
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCurrent ? roleColor : Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  partner.avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: roleColor.withOpacity(0.2),
                                    child: Icon(roleIcon, color: roleColor),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: roleColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: Icon(roleIcon, size: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),

                        // Partner Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    partner.name,
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: roleColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      partner.role.shortTitle,
                                      style: AppTextStyles.captionBold.copyWith(
                                        color: roleColor,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                partner.role.description,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.directions_car_rounded, size: 13, color: roleColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    partner.role.defaultVehicle,
                                    style: AppTextStyles.captionBold.copyWith(
                                      color: AppColors.textPrimary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('·', style: TextStyle(color: AppColors.textSecondary)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.star_rounded, size: 13, color: Color(0xFFD97706)),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${partner.rating}',
                                    style: AppTextStyles.captionBold.copyWith(
                                      color: const Color(0xFFB45309),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Active Indicator Radio/Check
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: roleColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                          )
                        else
                          Icon(
                            Icons.radio_button_unchecked_rounded,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}
