import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/selection_widgets.dart';
import '../../../core/widgets/cooli_cards_specialized.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/notification.dart';
import '../../../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationNotifierProvider);
    final allNotifs = notifState.notifications;

    final filteredNotifs = _selectedCategory == null
        ? allNotifs
        : allNotifs.where((n) => n.category == _selectedCategory).toList();

    return AppScaffold(
      header: BackHeader(
        title: 'Notifications',
        onBack: () => context.pop(),
        actions: [
          if (notifState.unreadCount > 0)
            TextButton(
              onPressed: () {
                ref.read(notificationNotifierProvider.notifier).markAllAsRead();
              },
              child: const Text(
                'Mark All Read',
                style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                FilterChipWidget(
                  label: 'All Alerts',
                  isSelected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: 'Jobs & Bids',
                  isSelected: _selectedCategory == NotificationCategory.jobs,
                  onTap: () => setState(() => _selectedCategory = NotificationCategory.jobs),
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: 'Payments',
                  isSelected: _selectedCategory == NotificationCategory.payments,
                  onTap: () => setState(() => _selectedCategory = NotificationCategory.payments),
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: 'Documents',
                  isSelected: _selectedCategory == NotificationCategory.documents,
                  onTap: () => setState(() => _selectedCategory = NotificationCategory.documents),
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: 'Promotions',
                  isSelected: _selectedCategory == NotificationCategory.promotions,
                  onTap: () => setState(() => _selectedCategory = NotificationCategory.promotions),
                ),
              ],
            ),
          ),

          // List of notifications
          Expanded(
            child: filteredNotifs.isEmpty
                ? const EmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: 'No Notifications',
                    message: 'You have no alerts matching the selected category.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    itemCount: filteredNotifs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filteredNotifs[index];
                      return CooliNotificationCard(
                        notification: item,
                        onTap: () {
                          ref.read(notificationNotifierProvider.notifier).markAsRead(item.id);
                          if (item.actionRoute != null) {
                            context.push(item.actionRoute!);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
