import 'package:cooli_partner/core/widgets/illustrations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/cooli_card.dart';
import '../../../core/widgets/info_rows.dart';
import '../../../core/widgets/timeline_widget.dart';
import '../../../core/widgets/partner_map.dart';
import '../../../core/widgets/cooli_text_fields.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';

class PorterDashboardScreen extends ConsumerStatefulWidget {
  const PorterDashboardScreen({super.key});

  @override
  ConsumerState<PorterDashboardScreen> createState() =>
      _PorterDashboardScreenState();
}

class _PorterDashboardScreenState extends ConsumerState<PorterDashboardScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _showPinDialog(PorterJob job) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Receiver Delivery PIN',
          style:
              AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ask receiver ${job.receiverName} for the 4-digit package drop confirmation PIN.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            CooliTextField(
              controller: _pinController,
              hintText: 'e.g. 7392',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Text(
              'Security Drop PIN: 7392',
              style: AppTextStyles.captionBold
                  .copyWith(color: AppColors.primaryBlue),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref
                  .read(porterNotifierProvider.notifier)
                  .verifyDropPin(_pinController.text.trim());
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Delivery confirmed! ₹850 credited to your account.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('VERIFY DROP',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final porterState = ref.watch(porterNotifierProvider);
    final job = porterState.job;

    if (job == null) {
      return AppScaffold(
        header:
            BackHeader(title: 'Porter Logistics', onBack: () => context.pop()),
        body: const Center(child: Text('No active porter order.')),
      );
    }

    String actionLabel;
    VoidCallback onAction;

    switch (job.state) {
      case PorterState.available:
      case PorterState.accepted:
        actionLabel = 'NAVIGATE TO PICKUP';
        onAction = () =>
            ref.read(porterNotifierProvider.notifier).advanceToNextState();
        break;
      case PorterState.goingToPickup:
        actionLabel = 'ARRIVED AT PICKUP';
        onAction = () =>
            ref.read(porterNotifierProvider.notifier).advanceToNextState();
        break;
      case PorterState.arrivedAtPickup:
        actionLabel = 'CONFIRM GOODS LOADED';
        onAction = () =>
            ref.read(porterNotifierProvider.notifier).advanceToNextState();
        break;
      case PorterState.goodsLoaded:
        actionLabel = 'START DELIVERY DISPATCH';
        onAction = () =>
            ref.read(porterNotifierProvider.notifier).advanceToNextState();
        break;
      case PorterState.deliveryStarted:
        actionLabel = 'ARRIVED AT DROP LOCATION';
        onAction = () =>
            ref.read(porterNotifierProvider.notifier).advanceToNextState();
        break;
      case PorterState.arrivedAtDrop:
        actionLabel = 'VERIFY RECEIVER PIN & COMPLETE';
        onAction = () => _showPinDialog(job);
        break;
      case PorterState.goodsDelivered:
      case PorterState.completed:
        actionLabel = 'ORDER COMPLETED ✓ (RETURN HOME)';
        onAction = () => context.go('/home');
        break;
      case PorterState.cancelled:
        actionLabel = 'ORDER CANCELLED';
        onAction = () => context.go('/home');
        break;
    }

    final timelineSteps = [
      TimelineStepItem(
        title: 'Booking Accepted',
        subtitle: 'Order assigned to your mini-truck',
        isCompleted: job.state.index > PorterState.accepted.index,
        isCurrent: job.state == PorterState.accepted,
      ),
      TimelineStepItem(
        title: 'Going to Pickup',
        subtitle: job.pickup.title,
        isCompleted: job.state.index > PorterState.goingToPickup.index,
        isCurrent: job.state == PorterState.goingToPickup,
      ),
      TimelineStepItem(
        title: 'Goods Loaded & Secured',
        subtitle: '${job.packageCount} Packages (${job.weightKg.toInt()} kg)',
        isCompleted: job.state.index > PorterState.goodsLoaded.index,
        isCurrent: job.state == PorterState.goodsLoaded,
      ),
      TimelineStepItem(
        title: 'In Transit to Destination',
        subtitle: job.dropoff.title,
        isCompleted: job.state.index > PorterState.deliveryStarted.index,
        isCurrent: job.state == PorterState.deliveryStarted,
      ),
      TimelineStepItem(
        title: 'Delivery Handover',
        subtitle: 'Receiver PIN verification',
        isCompleted: job.state == PorterState.completed,
        isCurrent: job.state == PorterState.arrivedAtDrop,
      ),
    ];

    return AppScaffold(
      header: BackHeader(
        title: 'Porter Goods Delivery',
        onBack: () => context.pop(),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue),
            onPressed: () =>
                ref.read(porterNotifierProvider.notifier).resetJob(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cargo Highlight Card
            CooliCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          RealCargoImage(
                              materialName: job.goodsType,
                              width: 56,
                              height: 56),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.goodsType,
                                style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                              Text(
                                '${job.weightKg.toInt()} kg · ${job.packageCount} Packages',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '₹${job.netEarnings.toStringAsFixed(0)}',
                        style: AppTextStyles.priceLarge.copyWith(
                            fontSize: 26, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Route details
                  RouteRow(
                    pickup: job.pickup.title,
                    destination: job.dropoff.title,
                    distanceText: '${job.distanceKm} km',
                    etaText: '${job.estimatedMinutes} min',
                  ),

                  if (job.loadingHelpRequired != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.handshake_outlined,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(job.loadingHelpRequired!,
                              style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live Route Map
            PartnerMap(
              height: 180,
              pickup: job.pickup,
              destination: job.dropoff,
              distanceKm: job.distanceKm,
              etaMinutes: job.estimatedMinutes,
            ),
            const SizedBox(height: 16),

            // Sender & Receiver Contact Card
            CooliCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InfoRow(
                    label: 'Pickup Sender',
                    value: job.senderName.split('(').first.trim(),
                    icon: Icons.person_outline_rounded,
                    trailing: IconButton(
                      icon: const Icon(Icons.call_rounded,
                          color: AppColors.success, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Calling sender ${job.senderPhone}...')),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 12),
                  InfoRow(
                    label: 'Drop Receiver',
                    value: job.receiverName.split('(').first.trim(),
                    icon: Icons.person_pin_circle_outlined,
                    trailing: IconButton(
                      icon: const Icon(Icons.call_rounded,
                          color: AppColors.success, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Calling receiver ${job.receiverPhone}...')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Visual Step Timeline
            CooliCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Workflow Progress',
                    style: AppTextStyles.titleMedium
                        .copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TimelineWidget(steps: timelineSteps),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Progression Action Button
            CooliGradientButton(
              label: actionLabel,
              icon: Icons.arrow_forward_rounded,
              onPressed: onAction,
            ),
          ],
        ),
      ),
    );
  }
}
