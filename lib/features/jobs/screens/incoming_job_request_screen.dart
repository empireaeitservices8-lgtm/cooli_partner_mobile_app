import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/partner_map.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/info_rows.dart';
import '../../../core/widgets/illustrations.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';

class IncomingJobRequestScreen extends ConsumerStatefulWidget {
  const IncomingJobRequestScreen({super.key});

  @override
  ConsumerState<IncomingJobRequestScreen> createState() => _IncomingJobRequestScreenState();
}

class _IncomingJobRequestScreenState extends ConsumerState<IncomingJobRequestScreen> {
  int _secondsLeft = AppConstants.jobRequestCountdownSeconds;
  Timer? _timer;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        setState(() {
          _secondsLeft = 0;
          _isExpired = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobsState = ref.watch(jobsNotifierProvider);
    final job = jobsState.incomingRequest ??
        (jobsState.availableJobs.isNotEmpty ? jobsState.availableJobs.first : null);

    if (job == null) {
      return AppScaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No Incoming Job at this moment.'),
              const SizedBox(height: 16),
              CooliPrimaryButton(
                label: 'BACK TO HOME',
                width: 200,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      );
    }

    final countdownProgress = _secondsLeft / AppConstants.jobRequestCountdownSeconds;

    return AppScaffold(
      body: Column(
        children: [
          // High Priority Top Alert Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: _isExpired
                  ? const LinearGradient(colors: [Color(0xFF64748B), Color(0xFF475569)])
                  : AppColors.primaryGradient,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isExpired ? Icons.timer_off_rounded : Icons.flash_on_rounded,
                        color: _isExpired ? AppColors.textSecondary : AppColors.accentOrange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isExpired ? 'REQUEST EXPIRED' : 'NEW JOB AVAILABLE',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                // Circular Countdown Timer
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        value: countdownProgress,
                        strokeWidth: 4,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _secondsLeft > 10 ? const Color(0xFF6EE7B7) : const Color(0xFFF87171),
                        ),
                      ),
                    ),
                    Text(
                      '00:${_secondsLeft.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Route Map Section
          Expanded(
            flex: 4,
            child: PartnerMap(
              pickup: job.pickup,
              destination: job.destination,
              distanceKm: job.distanceKm,
              etaMinutes: job.estimatedMinutes,
              height: double.infinity,
            ),
          ),

          // Bottom Job Details & Decision Panel
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price & Job Type Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        StatusBadge(
                          label: job.typeLabel,
                          type: BadgeType.info,
                          icon: Icons.local_taxi_rounded,
                        ),
                        const SizedBox(width: 10),
                        RatingWidget(rating: job.customerRating),
                      ],
                    ),
                    Text(
                      '₹${job.netEarnings.toStringAsFixed(0)}',
                      style: AppTextStyles.numberDisplayLarge.copyWith(
                        fontSize: 34,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Customer info with avatar & real vehicle/cargo image
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.12),
                      child: Text(
                        job.customerName.isNotEmpty ? job.customerName[0] : 'C',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.customerName,
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          Text(
                            job.vehicleRequired,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (job.type == JobType.truck || job.type == JobType.porter)
                      RealCargoImage(materialName: job.packageDetails ?? 'Package', width: 44, height: 44, borderRadius: 10)
                    else
                      Container(
                        width: 50,
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset('assets/images/mini_truck.jpg', fit: BoxFit.cover),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Route indicator
                RouteRow(
                  pickup: job.pickup.title,
                  destination: job.destination.title,
                  distanceText: '${job.distanceKm} km',
                  etaText: '${job.estimatedMinutes} min',
                ),

                const SizedBox(height: 24),

                // Action Buttons: ACCEPT (Visually Dominant) vs DECLINE
                if (_isExpired) ...[
                  CooliSecondaryButton(
                    label: 'CLOSE',
                    onPressed: () => context.pop(),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: CooliSecondaryButton(
                          label: 'DECLINE',
                          textColor: AppColors.textSecondary,
                          onPressed: () {
                            ref.read(jobsNotifierProvider.notifier).declineJob(job.id);
                            context.pop();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: CooliGradientButton(
                          label: 'ACCEPT NOW',
                          icon: Icons.check_circle_rounded,
                          onPressed: () async {
                            await ref.read(jobsNotifierProvider.notifier).acceptJob(job.id);
                            if (context.mounted) {
                              context.pop();
                              if (job.type == JobType.ride) {
                                context.push('/ride/active');
                              } else if (job.type == JobType.porter) {
                                context.push('/porter');
                              } else {
                                context.push('/truck');
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
