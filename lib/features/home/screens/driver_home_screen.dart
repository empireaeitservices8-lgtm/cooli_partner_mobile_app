import 'package:cooli_partner/core/widgets/cooli_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/online_status_toggle.dart';
import '../../../core/widgets/selection_widgets.dart';
import '../../../core/widgets/cooli_card.dart';
import '../../../core/widgets/cooli_cards_specialized.dart';
import '../../../core/widgets/partner_map.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/partner_switcher_modal.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partnerState = ref.watch(partnerNotifierProvider);
    final partner = partnerState.partner;
    final isOnline = partner.isOnline;
    final jobsState = ref.watch(jobsNotifierProvider);
    final notificationState = ref.watch(notificationNotifierProvider);
    final earningsState = ref.watch(earningsNotifierProvider);

    return AppScaffold(
      header: AppHeader(
        driverName: partner.name.split(' ').first,
        rating: partner.rating,
        unreadNotifications: notificationState.unreadCount,
        onNotificationTap: () => context.push('/notifications'),
        onProfileTap: () => context.push('/profile'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(jobsNotifierProvider.notifier).loadJobs();
          await ref.read(earningsNotifierProvider.notifier).loadEarnings();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.only(bottom: 96), // room for floating bottom nav
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Multi-User Persona Switcher Banner (4 Users in 1 App)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: GestureDetector(
                  onTap: () => showPartnerSwitcherModal(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _getRoleColor(partner.role).withOpacity(0.3), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: _getRoleColor(partner.role).withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: _getRoleColor(partner.role).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_getRoleIcon(partner.role), color: _getRoleColor(partner.role), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'REGISTERED: ${partner.role.title.toUpperCase()}',
                                    style: AppTextStyles.captionBold.copyWith(color: _getRoleColor(partner.role), fontSize: 13),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceMuted,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('4 ROLES IN 1 APP', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                                  ),
                                ],
                              ),
                              Text(
                                'Logged in as ${partner.name} • Tap to switch persona',
                                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.swap_horiz_rounded, color: AppColors.textTertiary, size: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // Pending Verification Warning Alert Banner (if applicable)
              if (partner.status == PartnerStatus.pendingVerification)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account Verification Pending',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF92400E)),
                              ),
                              Text(
                                'Your documents are currently under review. Online bookings are locked until approval.',
                                style: AppTextStyles.caption.copyWith(color: const Color(0xFFB45309), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton(
                          onPressed: () => context.push('/verification-status', extra: partner.phone),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('STATUS', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),

              // Online / Offline Status Toggle Banner
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: OnlineStatusToggle(
                  isOnline: isOnline && partner.status == PartnerStatus.active,
                  onToggle: (val) {
                    if (partner.status != PartnerStatus.active) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Cannot go online: Account verification is pending review.'),
                          backgroundColor: const Color(0xFFD97706),
                          action: SnackBarAction(
                            label: 'VIEW STATUS',
                            textColor: Colors.white,
                            onPressed: () => context.push('/verification-status', extra: partner.phone),
                          ),
                        ),
                      );
                      return;
                    }
                    ref
                        .read(partnerNotifierProvider.notifier)
                        .toggleOnlineStatus();
                  },
                ),
              ),

              // Role Authorization Card (Single-Role Mode) or Work Mode Selector (Fleet Owner)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: partner.role == PartnerRole.fleetOwner
                    ? WorkModeSelector(
                        selected: partner.workPreference,
                        onSelected: (pref) {
                          ref
                              .read(partnerNotifierProvider.notifier)
                              .setWorkPreference(pref);
                          JobType? filter;
                          if (pref == WorkPreference.rides) filter = JobType.ride;
                          if (pref == WorkPreference.porter) filter = JobType.porter;
                          if (pref == WorkPreference.truck) filter = JobType.truck;
                          ref.read(jobsNotifierProvider.notifier).setFilter(filter);
                        },
                      )
                    : Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getRoleColor(partner.role).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getRoleColor(partner.role).withOpacity(0.25),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _getRoleColor(partner.role).withOpacity(0.2)),
                              ),
                              child: Icon(_getRoleIcon(partner.role), color: _getRoleColor(partner.role), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        partner.role.defaultVehicle,
                                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 13),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle_rounded, size: 10, color: AppColors.success),
                                            SizedBox(width: 3),
                                            Text('ACTIVE', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.success)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    partner.role.description,
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              // Today's Performance Stat Row
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: StatCard(
                        title: "Today's Earnings",
                        value:
                            '₹${earningsState.summary.todayEarnings.toStringAsFixed(0)}',
                        subtitle: '+12%',
                        icon: Icons.currency_rupee_rounded,
                        iconColor: AppColors.primaryBlue,
                        iconBackgroundColor: AppColors.infoLight,
                        onTap: () => context.push('/earnings'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: StatCard(
                        title: 'Trips Done',
                        value: '${earningsState.summary.completedTrips}',
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: AppColors.success,
                        iconBackgroundColor: const Color(0xFFDCFCE7),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: StatCard(
                        title: 'Online Time',
                        value: '7h 20m',
                        icon: Icons.timer_outlined,
                        iconColor: AppColors.accentOrangeDark,
                        iconBackgroundColor: const Color(0xFFFEF3C7),
                      ),
                    ),
                  ],
                ),
              ),

              // Interactive Route & Logistics Partner Map Section
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Live Logistics Map',
                      actionLabel: 'Center',
                      onAction: () {},
                    ),
                    PartnerMap(
                      height: 200,
                      pickup: jobsState.availableJobs.isNotEmpty
                          ? jobsState.availableJobs.first.pickup
                          : null,
                      destination: jobsState.availableJobs.isNotEmpty
                          ? jobsState.availableJobs.first.destination
                          : null,
                      distanceKm: jobsState.availableJobs.isNotEmpty
                          ? jobsState.availableJobs.first.distanceKm
                          : null,
                      etaMinutes: jobsState.availableJobs.isNotEmpty
                          ? jobsState.availableJobs.first.estimatedMinutes
                          : null,
                    ),
                  ],
                ),
              ),

              // Quick Operations Grid (Strictly tailored to registered partner type)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: '${partner.role.title} Operations'),
                    _buildQuickOperations(context, partner.role),
                  ],
                ),
              ),

              // Available Jobs Section (Strictly displaying only registered role jobs)
              () {
                final filteredJobs = jobsState.availableJobs.where((j) {
                  if (partner.role == PartnerRole.fleetOwner) return true;
                  return j.type == partner.role.associatedJobType;
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available ${partner.role.title} Jobs (${filteredJobs.length})',
                            style: AppTextStyles.titleMedium
                                .copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          // Incoming Request Demo Simulator Button
                          ActionChip(
                            avatar: const Icon(Icons.ring_volume_rounded,
                                size: 14, color: Colors.white),
                            label: const Text('Simulate Incoming'),
                            backgroundColor: _getRoleColor(partner.role),
                            labelStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                            onPressed: () {
                              if (filteredJobs.isNotEmpty) {
                                ref
                                    .read(jobsNotifierProvider.notifier)
                                    .triggerIncomingJob(filteredJobs.first);
                                context.push('/jobs/request');
                              } else if (jobsState.availableJobs.isNotEmpty) {
                                ref
                                    .read(jobsNotifierProvider.notifier)
                                    .triggerIncomingJob(jobsState.availableJobs.first);
                                context.push('/jobs/request');
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    if (!isOnline)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        child: CooliCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Icon(Icons.power_settings_new_rounded,
                                  size: 40, color: AppColors.textTertiary),
                              const SizedBox(height: 10),
                              Text(
                                "You're Currently Offline",
                                style: AppTextStyles.titleMedium
                                    .copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Turn on your online status to receive instant ${partner.role.title.toLowerCase()} assignments.",
                                style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              CooliPrimaryButton(
                                label: 'GO ONLINE NOW',
                                icon: Icons.play_arrow_rounded,
                                height: 46,
                                onPressed: () {
                                  ref
                                      .read(partnerNotifierProvider.notifier)
                                      .toggleOnlineStatus();
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (jobsState.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: LoadingState(
                            message: 'Scanning available assignments around you...'),
                      )
                    else if (filteredJobs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        child: EmptyState.noJobs(
                          onGoOnline: () =>
                              ref.read(jobsNotifierProvider.notifier).loadJobs(),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredJobs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final job = filteredJobs[index];
                            return CooliJobCard(
                              job: job,
                              onAccept: () async {
                                await ref
                                    .read(jobsNotifierProvider.notifier)
                                    .acceptJob(job.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Accepted ${job.typeLabel} assignment!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                  if (job.type == JobType.ride) {
                                    context.push('/ride/active');
                                  } else if (job.type == JobType.porter) {
                                    context.push('/porter');
                                  } else {
                                    context.push('/truck');
                                  }
                                }
                              },
                              onDecline: () {
                                ref
                                    .read(jobsNotifierProvider.notifier)
                                    .declineJob(job.id);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                );
              }(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickOperations(BuildContext context, PartnerRole role) {
    switch (role) {
      case PartnerRole.rider:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    label: 'Active Ride Trip',
                    subtitle: 'Customer meter & ETA',
                    icon: Icons.local_taxi_rounded,
                    color: AppColors.primaryBlue,
                    onTap: () => context.push('/ride/active'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: QuickActionCard(
                    label: 'Ride Bookings',
                    subtitle: 'City passenger requests',
                    icon: Icons.hail_rounded,
                    color: const Color(0xFF0284C7),
                    onTap: () => context.push('/jobs'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    label: 'Trip Fares & UPI',
                    subtitle: 'Daily collections',
                    icon: Icons.payments_outlined,
                    color: AppColors.success,
                    onTap: () => context.push('/earnings'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: QuickActionCard(
                    label: 'Ride Safety & SOS',
                    subtitle: '24/7 emergency assist',
                    icon: Icons.shield_outlined,
                    color: AppColors.error,
                    onTap: () => context.push('/safety'),
                  ),
                ),
              ],
            ),
          ],
        );

      case PartnerRole.porter:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    label: 'Porter Cargo',
                    subtitle: 'Active shifting order',
                    icon: Icons.inventory_2_rounded,
                    color: const Color(0xFFD97706),
                    onTap: () => context.push('/porter'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: QuickActionCard(
                    label: 'Goods Shifting',
                    subtitle: 'Cartons & parcels feed',
                    icon: Icons.assignment_rounded,
                    color: const Color(0xFFB45309),
                    onTap: () => context.push('/jobs'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    label: 'Receiver PIN',
                    subtitle: 'Secure delivery OTP',
                    icon: Icons.pin_rounded,
                    color: AppColors.primaryBlue,
                    onTap: () => context.push('/porter'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: QuickActionCard(
                    label: 'Tata Ace Specs',
                    subtitle: 'Payload & permits',
                    icon: Icons.local_shipping_outlined,
                    color: AppColors.success,
                    onTap: () => context.push('/vehicles'),
                  ),
                ),
              ],
            ),
          ],
        );

      case PartnerRole.truckDriver:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    label: 'Truck Freight',
                    subtitle: 'Interstate load board',
                    icon: Icons.local_shipping_rounded,
                    color: AppColors.secondaryPurple,
                    onTap: () => context.push('/truck'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: QuickActionCard(
                    label: 'Truck Bids',
                    subtitle: 'Counter offers & status',
                    icon: Icons.gavel_rounded,
                    color: const Color(0xFF7C3AED),
                    onTap: () => context.push('/truck/bids'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    label: '16T Heavy Carrier',
                    subtitle: 'Commercial specs & FC',
                    icon: Icons.fire_truck_outlined,
                    color: AppColors.primaryBlue,
                    onTap: () => context.push('/vehicles'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: QuickActionCard(
                    label: 'Diesel & Tolls',
                    subtitle: 'Trip advances & claims',
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppColors.success,
                    onTap: () => context.push('/earnings'),
                  ),
                ),
              ],
            ),
          ],
        );

      case PartnerRole.fleetOwner:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    label: 'Commercial Fleet',
                    subtitle: '5+ vehicles & drivers',
                    icon: Icons.domain_rounded,
                    color: const Color(0xFF059669),
                    onTap: () => context.push('/vehicles'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: QuickActionCard(
                    label: 'Bulk Freight',
                    subtitle: 'Enterprise loads board',
                    icon: Icons.local_shipping_rounded,
                    color: AppColors.secondaryPurple,
                    onTap: () => context.push('/truck'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    label: 'Fleet Bids',
                    subtitle: 'Manage contracts & rates',
                    icon: Icons.gavel_rounded,
                    color: const Color(0xFF7C3AED),
                    onTap: () => context.push('/truck/bids'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: QuickActionCard(
                    label: 'Driver Payouts',
                    subtitle: 'Settlements & ledger',
                    icon: Icons.payments_rounded,
                    color: AppColors.primaryBlue,
                    onTap: () => context.push('/earnings'),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  Color _getRoleColor(PartnerRole role) {
    switch (role) {
      case PartnerRole.rider:
        return AppColors.primaryBlue;
      case PartnerRole.porter:
        return const Color(0xFFD97706);
      case PartnerRole.truckDriver:
        return AppColors.secondaryPurple;
      case PartnerRole.fleetOwner:
        return const Color(0xFF059669);
    }
  }

  IconData _getRoleIcon(PartnerRole role) {
    switch (role) {
      case PartnerRole.rider:
        return Icons.local_taxi_rounded;
      case PartnerRole.porter:
        return Icons.inventory_2_rounded;
      case PartnerRole.truckDriver:
        return Icons.local_shipping_rounded;
      case PartnerRole.fleetOwner:
        return Icons.domain_rounded;
    }
  }
}
