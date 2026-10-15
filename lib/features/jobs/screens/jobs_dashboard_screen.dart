import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/selection_widgets.dart';
import '../../../core/widgets/cooli_cards_specialized.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';

class JobsDashboardScreen extends ConsumerStatefulWidget {
  const JobsDashboardScreen({super.key});

  @override
  ConsumerState<JobsDashboardScreen> createState() => _JobsDashboardScreenState();
}

class _JobsDashboardScreenState extends ConsumerState<JobsDashboardScreen> {
  int _selectedTabIndex = 0; // 0: Available, 1: Accepted, 2: Completed History
  final List<String> _tabs = const ['Available', 'Accepted', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final jobsState = ref.watch(jobsNotifierProvider);
    final partnerState = ref.watch(partnerNotifierProvider);
    final partner = partnerState.partner;
    final selectedFilter = jobsState.selectedFilter;

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jobs Management',
                      style: AppTextStyles.headline.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Role: ${partner.role.title} (${partner.role.shortTitle})',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue),
                  onPressed: () => ref.read(jobsNotifierProvider.notifier).loadJobs(),
                ),
              ],
            ),
          ),

          // Primary Tab Selector: Available | Accepted | Completed
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: TabSelector(
              tabs: _tabs,
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
          ),

          // Role-Locked Banner for Single-Role Partners vs Multi-Class Fleet Owner
          if (partner.role != PartnerRole.fleetOwner)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: _getRoleColor(partner.role).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _getRoleColor(partner.role).withOpacity(0.3), width: 1.2),
              ),
              child: Row(
                children: [
                  Icon(_getRoleIcon(partner.role), size: 20, color: _getRoleColor(partner.role)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Showing ONLY Registered ${partner.role.title} Bookings',
                          style: AppTextStyles.captionBold.copyWith(
                            color: _getRoleColor(partner.role),
                            fontSize: 12.5,
                          ),
                        ),
                        Text(
                          partner.role.description,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getRoleColor(partner.role),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'REGISTERED',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          else
            // Fleet Owner has full commercial fleet controls
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Row(
                children: [
                  FilterChipWidget(
                    label: 'All Commercial Freight',
                    isSelected: selectedFilter == null,
                    onTap: () => ref.read(jobsNotifierProvider.notifier).setFilter(null),
                  ),
                  const SizedBox(width: 8),
                  FilterChipWidget(
                    label: 'Porter Cargo (Mini-Truck)',
                    isSelected: selectedFilter == JobType.porter,
                    onTap: () => ref.read(jobsNotifierProvider.notifier).setFilter(JobType.porter),
                  ),
                  const SizedBox(width: 8),
                  FilterChipWidget(
                    label: 'Truck Freight (Heavy)',
                    isSelected: selectedFilter == JobType.truck,
                    onTap: () => ref.read(jobsNotifierProvider.notifier).setFilter(JobType.truck),
                  ),
                ],
              ),
            ),

          // Content List
          Expanded(
            child: _buildJobsList(jobsState),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList(JobsState state) {
    if (state.isLoading) {
      return const LoadingState(message: 'Updating jobs feed...');
    }

    List<Job> targetList;
    if (_selectedTabIndex == 0) {
      targetList = state.availableJobs;
    } else if (_selectedTabIndex == 1) {
      targetList = state.acceptedJobs;
    } else {
      targetList = state.historyJobs;
    }

    if (targetList.isEmpty) {
      if (_selectedTabIndex == 0) {
        return EmptyState.noJobs(
          onGoOnline: () => ref.read(jobsNotifierProvider.notifier).loadJobs(),
        );
      } else if (_selectedTabIndex == 1) {
        return const EmptyState(
          icon: Icons.assignment_outlined,
          title: 'No Accepted Jobs',
          message: 'Accept an available booking from the Available tab to start a delivery or ride.',
        );
      } else {
        return const EmptyState(
          icon: Icons.history_rounded,
          title: 'No Completed Jobs Yet',
          message: 'Your completed rides, porter dispatches, and heavy freight trips will appear here.',
        );
      }
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: targetList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final job = targetList[index];
        return CooliJobCard(
          job: job,
          onAccept: () async {
            if (_selectedTabIndex == 0) {
              await ref.read(jobsNotifierProvider.notifier).acceptJob(job.id);
              if (mounted) {
                if (job.type == JobType.ride) {
                  context.push('/ride/active');
                } else if (job.type == JobType.porter) {
                  context.push('/porter');
                } else {
                  context.push('/truck');
                }
              }
            } else {
              // Open active workflow
              if (job.type == JobType.ride) {
                context.push('/ride/active');
              } else if (job.type == JobType.porter) {
                context.push('/porter');
              } else {
                context.push('/truck');
              }
            }
          },
          onDecline: _selectedTabIndex == 0
              ? () => ref.read(jobsNotifierProvider.notifier).declineJob(job.id)
              : null,
        );
      },
    );
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
