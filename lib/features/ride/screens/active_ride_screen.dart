import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/partner_map.dart';
import '../../../core/widgets/dialogs_and_sheets.dart';
import '../../../core/widgets/cooli_text_fields.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';

class ActiveRideScreen extends ConsumerStatefulWidget {
  const ActiveRideScreen({super.key});

  @override
  ConsumerState<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends ConsumerState<ActiveRideScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _showSosConfirmation() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'EMERGENCY SOS',
      message:
          'This will immediately alert COOLI 24/7 Security Operations & Local Emergency Response (112) with your live GPS location.',
      confirmLabel: 'TRIGGER SOS',
      cancelLabel: 'DISMISS',
      isDangerous: true,
      icon: Icons.emergency_rounded,
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'SOS Emergency broadcast initiated! Dispatching assistance.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showOtpDialog(Ride ride) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Enter Passenger Start OTP',
          style:
              AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ask passenger ${ride.passengerName} for their 4-digit trip start PIN.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            CooliTextField(
              controller: _otpController,
              hintText: 'e.g. 4821',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Text(
              'Demo PIN: 4821',
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
                  .read(rideNotifierProvider.notifier)
                  .verifyOtp(_otpController.text.trim());
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Trip started successfully! Drive safely.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue),
            child: const Text('START TRIP',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rideState = ref.watch(rideNotifierProvider);
    final ride = rideState.ride;

    if (ride == null) {
      return AppScaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No active ride session.'),
              const SizedBox(height: 16),
              CooliPrimaryButton(
                label: 'RETURN TO HOME',
                width: 200,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      );
    }

    // Determine current progression button label
    String actionButtonLabel;
    VoidCallback onActionTap;

    switch (ride.state) {
      case RideState.requested:
      case RideState.accepted:
        actionButtonLabel = 'START NAVIGATION TO PICKUP';
        onActionTap =
            () => ref.read(rideNotifierProvider.notifier).advanceToNextState();
        break;
      case RideState.navigatingToPickup:
        actionButtonLabel = 'ARRIVED AT PICKUP';
        onActionTap =
            () => ref.read(rideNotifierProvider.notifier).advanceToNextState();
        break;
      case RideState.arrivedAtPickup:
      case RideState.passengerPicked:
        actionButtonLabel = 'ENTER OTP & START TRIP';
        onActionTap = () => _showOtpDialog(ride);
        break;
      case RideState.tripStarted:
      case RideState.inProgress:
        actionButtonLabel = 'ARRIVED AT DESTINATION';
        onActionTap =
            () => ref.read(rideNotifierProvider.notifier).advanceToNextState();
        break;
      case RideState.arrivedAtDestination:
        actionButtonLabel = 'COMPLETE TRIP & COLLECT PAYMENT';
        onActionTap = () async {
          await ref.read(rideNotifierProvider.notifier).advanceToNextState();
          if (mounted) {
            context.push('/ride/completed');
          }
        };
        break;
      case RideState.completed:
      case RideState.paymentReceived:
      case RideState.rated:
        actionButtonLabel = 'VIEW TRIP RECEIPT';
        onActionTap = () => context.push('/ride/completed');
        break;
      case RideState.cancelled:
        actionButtonLabel = 'TRIP CANCELLED - RETURN HOME';
        onActionTap = () => context.go('/home');
        break;
    }

    final isCompact = MediaQuery.of(context).size.width < 390;

    return AppScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final panelWidth =
              constraints.maxWidth > 700 ? 700.0 : constraints.maxWidth;
          return Stack(
            children: [
              Positioned.fill(
                child: PartnerMap(
                  height: MediaQuery.of(context).size.height,
                  pickup: ride.pickup,
                  destination: ride.dropoff,
                  distanceKm: ride.distanceKm,
                  etaMinutes: ride.durationMinutes,
                  showControls: false,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                child: SafeArea(
                  top: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: AppColors.softShadow,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 20, color: AppColors.textPrimary),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getStatusLabel(ride.state),
                              style: AppTextStyles.captionBold
                                  .copyWith(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withOpacity(0.38),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.sos_rounded,
                              color: Colors.white, size: 22),
                          onPressed: _showSosConfirmation,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: panelWidth),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                          isCompact ? 16 : 20, 16, isCompact ? 16 : 20, 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28)),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.cardBorder,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: isCompact ? 44 : 48,
                                  height: isCompact ? 44 : 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.primaryBlue
                                            .withOpacity(0.25),
                                        width: 1.5),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/driver_avatar.jpg',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: AppColors.infoLight,
                                        child: const Icon(Icons.person_rounded,
                                            color: AppColors.primaryBlue,
                                            size: 28),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ride.passengerName,
                                        style: AppTextStyles.titleMedium
                                            .copyWith(
                                                fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded,
                                              size: 14,
                                              color: Color(0xFFD97706)),
                                          const SizedBox(width: 3),
                                          Text(
                                            ride.passengerRating
                                                .toStringAsFixed(1),
                                            style: AppTextStyles.captionBold
                                                .copyWith(
                                                    color: const Color(
                                                        0xFFB45309)),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Cash / Online',
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                    color: AppColors
                                                        .textSecondary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    _buildQuickAction(
                                      icon: Icons.call_rounded,
                                      label: 'Call',
                                      tooltip: 'Call passenger',
                                      background: AppColors.successLight,
                                      iconColor: AppColors.success,
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Calling passenger ${ride.passengerPhone}...')),
                                        );
                                      },
                                    ),
                                    _buildQuickAction(
                                      icon: Icons.chat_bubble_outline_rounded,
                                      label: 'Chat',
                                      tooltip: 'Open secure chat',
                                      background: AppColors.infoLight,
                                      iconColor: AppColors.primaryBlue,
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Opening secure partner chat...')),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            LayoutBuilder(
                              builder: (context, innerConstraints) {
                                final infoIsCompact =
                                    innerConstraints.maxWidth < 320;
                                return infoIsCompact
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildRouteInfo(
                                            title: ride.state.index <
                                                    RideState.tripStarted.index
                                                ? 'Pickup point'
                                                : 'Dropoff point',
                                            value: ride.state.index <
                                                    RideState.tripStarted.index
                                                ? ride.pickup.title
                                                    .split(',')
                                                    .first
                                                : ride.dropoff.title
                                                    .split(',')
                                                    .first,
                                          ),
                                          const SizedBox(height: 12),
                                          _buildRouteInfo(
                                            title: 'Trip earnings',
                                            value:
                                                '₹${ride.netEarnings.toStringAsFixed(0)}',
                                            isAmount: true,
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildRouteInfo(
                                            title: ride.state.index <
                                                    RideState.tripStarted.index
                                                ? 'Pickup point'
                                                : 'Dropoff point',
                                            value: ride.state.index <
                                                    RideState.tripStarted.index
                                                ? ride.pickup.title
                                                    .split(',')
                                                    .first
                                                : ride.dropoff.title
                                                    .split(',')
                                                    .first,
                                          ),
                                          _buildRouteInfo(
                                            title: 'Trip earnings',
                                            value:
                                                '₹${ride.netEarnings.toStringAsFixed(0)}',
                                            isAmount: true,
                                          ),
                                        ],
                                      );
                              },
                            ),
                            const SizedBox(height: 18),
                            CooliGradientButton(
                              label: actionButtonLabel,
                              icon: Icons.navigation_rounded,
                              onPressed: onActionTap,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required String tooltip,
    required Color background,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Text(label,
                  style: AppTextStyles.captionBold
                      .copyWith(color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInfo({
    required String title,
    required String value,
    bool isAmount = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.captionBold
              .copyWith(color: AppColors.textTertiary, letterSpacing: 0.8),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: isAmount
              ? AppTextStyles.priceMedium.copyWith(fontWeight: FontWeight.w900)
              : AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  String _getStatusLabel(RideState state) {
    switch (state) {
      case RideState.requested:
      case RideState.accepted:
        return 'Accepted';
      case RideState.navigatingToPickup:
        return 'Going to Pickup';
      case RideState.arrivedAtPickup:
        return 'Driver Arrived';
      case RideState.passengerPicked:
        return 'Passenger Boarded';
      case RideState.tripStarted:
      case RideState.inProgress:
        return 'Trip in Progress';
      case RideState.arrivedAtDestination:
        return 'Arrived at Drop';
      case RideState.completed:
        return 'Completed';
      case RideState.paymentReceived:
        return 'Payment Received';
      case RideState.rated:
        return 'Trip Rated';
      case RideState.cancelled:
        return 'Cancelled';
    }
  }
}
