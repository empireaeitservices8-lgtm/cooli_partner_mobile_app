import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/cooli_card.dart';
import '../../../core/widgets/info_rows.dart';
import '../../../core/widgets/partner_map.dart';
import '../../../core/widgets/illustrations.dart';
import '../../../core/widgets/selection_widgets.dart';
import '../../../models/models.dart';

class TruckLoadDetailsScreen extends StatelessWidget {
  final TruckLoad load;

  const TruckLoadDetailsScreen({super.key, required this.load});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: BackHeader(
        title: 'Freight Load Specs',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Real Cargo Load Hero Photo
            Container(
              height: 180,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.cardShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      load.material.toLowerCase().contains('apple')
                          ? 'assets/images/load_apples.jpg'
                          : 'assets/images/load_electronics.jpg',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.65),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 14,
                      right: 14,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            load.material,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              load.weightDescription,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hero Cargo Card
            CooliCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RealCargoImage(materialName: load.material, width: 72, height: 72),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              load.material,
                              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 18),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                AppChip(label: load.weightDescription, icon: Icons.scale_rounded),
                                const SizedBox(width: 6),
                                AppChip(label: load.vehicleRequired, icon: Icons.local_shipping_rounded),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Pricing Highlights
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Shipper Offer', style: AppTextStyles.caption),
                          const SizedBox(height: 2),
                          Text(
                            '₹${load.customerOfferedPrice.toStringAsFixed(0)}',
                            style: AppTextStyles.priceLarge.copyWith(fontSize: 24),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Fair Market Rate', style: AppTextStyles.caption),
                          const SizedBox(height: 2),
                          Text(
                            '₹${load.suggestedPrice.toStringAsFixed(0)}',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.accentOrangeDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Route Map Preview
            PartnerMap(
              height: 180,
              pickup: load.pickup,
              destination: load.destination,
              distanceKm: load.distanceKm,
            ),
            const SizedBox(height: 16),

            // Specification Matrix
            CooliCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transit Specifications',
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  InfoRow(label: 'Distance', value: '${load.distanceKm} km', icon: Icons.straighten_rounded),
                  InfoRow(label: 'Loading Facility', value: load.loadingType, icon: Icons.inventory_2_rounded),
                  InfoRow(
                    label: 'Target Delivery',
                    value: DateFormat('hh:mm a, dd MMM').format(load.deliveryDeadline),
                    icon: Icons.access_time_rounded,
                  ),
                  InfoRow(label: 'Shipper', value: load.shipperName, icon: Icons.business_rounded),
                  if (load.notes != null) ...[
                    const Divider(height: 16),
                    Text('Shipper Handling Instructions:', style: AppTextStyles.captionBold),
                    const SizedBox(height: 4),
                    Text(load.notes!, style: AppTextStyles.bodySmall),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Decision Buttons (ACCEPT vs BID)
            Row(
              children: [
                Expanded(
                  child: CooliSecondaryButton(
                    label: 'PLACE BID',
                    icon: Icons.gavel_rounded,
                    height: 52,
                    onPressed: () => context.push('/truck/bid', extra: load),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CooliPrimaryButton(
                    label: 'ACCEPT (₹${load.customerOfferedPrice.toInt()})',
                    height: 52,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Accepted load at ₹${load.customerOfferedPrice.toInt()}! Ready for dispatch.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      context.pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
