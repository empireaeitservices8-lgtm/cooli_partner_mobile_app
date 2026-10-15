import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/cooli_card.dart';
import '../../../core/widgets/info_rows.dart';
import '../../../providers/providers.dart';

class RideCompletedScreen extends ConsumerWidget {
  const RideCompletedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rideState = ref.watch(rideNotifierProvider);
    final ride = rideState.ride;

    final double baseFare = ride?.baseFare ?? 200.0;
    final double distanceFare = ride?.distanceFare ?? 220.0;
    final double commission = ride?.commission ?? 40.0;
    final double netEarnings = ride?.netEarnings ?? 380.0;

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Success Checkmark
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 50),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Trip Completed ✓',
              style: AppTextStyles.headline.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Trip payout credited to your COOLI Partner wallet',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 28),

            // Large Net Earnings Card
            CooliCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('NET EARNINGS', style: AppTextStyles.captionBold.copyWith(color: AppColors.textTertiary)),
                  const SizedBox(height: 6),
                  Text(
                    '₹${netEarnings.toStringAsFixed(0)}',
                    style: AppTextStyles.numberDisplayLarge.copyWith(color: AppColors.primaryBlue),
                  ),
                  const Divider(height: 32),

                  // Fare Breakdown
                  PriceRow(title: 'Base Fare', amount: baseFare),
                  PriceRow(title: 'Distance Fare (${ride?.distanceKm ?? 12.4} km)', amount: distanceFare),
                  PriceRow(title: 'Platform Commission', amount: commission, isNegative: true),
                  const Divider(height: 24),
                  PriceRow(title: 'Net Partner Payout', amount: netEarnings, isTotal: true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Trip Route Summary
            if (ride != null)
              CooliCard(
                padding: const EdgeInsets.all(16),
                child: RouteRow(
                  pickup: ride.pickup.title,
                  destination: ride.dropoff.title,
                  distanceText: '${ride.distanceKm} km',
                  etaText: '${ride.durationMinutes} min',
                ),
              ),

            const SizedBox(height: 36),

            // Proceed to rating
            CooliPrimaryButton(
              label: 'DONE & RATE PASSENGER',
              icon: Icons.star_rate_rounded,
              onPressed: () => context.push('/ride/rating'),
            ),
          ],
        ),
      ),
    );
  }
}
