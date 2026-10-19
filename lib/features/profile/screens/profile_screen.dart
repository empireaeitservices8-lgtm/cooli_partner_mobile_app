import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/cooli_card.dart';
import '../../../core/widgets/dialogs_and_sheets.dart';
import '../../../core/widgets/partner_switcher_modal.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _onLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Log Out of COOLI Partner?',
      message: 'You will not receive any new ride notifications or freight loads while logged out.',
      confirmLabel: 'LOG OUT',
      cancelLabel: 'STAY LOGGED IN',
      isDangerous: true,
      icon: Icons.logout_rounded,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partnerState = ref.watch(partnerNotifierProvider);
    final partner = partnerState.partner;

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          children: [
            // Profile Header Card
            ProfileHeader(
              name: partner.name,
              partnerId: partner.id,
              rating: partner.rating,
              vehicleName: '${partner.role.defaultVehicle} • ${partner.role.title}',
            ),
            const SizedBox(height: 20),

            // Navigation Menu Card 1: Operations
            CooliCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.supervised_user_circle_outlined,
                    title: 'Switch Partner Persona (4 Roles)',
                    subtitle: '${partner.name} · ${partner.role.title}',
                    onTap: () => showPartnerSwitcherModal(context, ref),
                  ),
                  const Divider(indent: 56),
                  _buildMenuItem(
                    icon: Icons.badge_outlined,
                    title: 'Personal Information',
                    subtitle: 'Name, phone, and profile credentials',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Viewing credentials for ${partner.name}')),
                      );
                    },
                  ),
                  const Divider(indent: 56),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Documents & Permits',
                    subtitle: 'Driving license, RC, insurance',
                    onTap: () => context.push('/documents'),
                  ),
                  const Divider(indent: 56),
                  _buildMenuItem(
                    icon: Icons.local_shipping_outlined,
                    title: 'Vehicles & Fleet',
                    subtitle: 'Manage mini-trucks and carriers',
                    onTap: () => context.push('/vehicles'),
                  ),
                  const Divider(indent: 56),
                  _buildMenuItem(
                    icon: Icons.account_balance_outlined,
                    title: 'Bank Settlement Account',
                    subtitle: 'HDFC Bank (•••• 4521)',
                    onTap: () => context.push('/profile/bank'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Navigation Menu Card 2: Performance & Community
            CooliCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.star_outline_rounded,
                    title: 'Ratings & Customer Reviews',
                    subtitle: 'Overall rating 4.86 (342 reviews)',
                    onTap: () => context.push('/profile/ratings'),
                  ),
                  const Divider(indent: 56),
                  _buildMenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notification Center',
                    subtitle: 'Alerts, surge incentives, payouts',
                    onTap: () => context.push('/notifications'),
                  ),
                  const Divider(indent: 56),
                  _buildMenuItem(
                    icon: Icons.shield_outlined,
                    title: 'Safety Center & SOS',
                    subtitle: 'Emergency contacts and assistance',
                    onTap: () => context.push('/safety'),
                  ),
                  const Divider(indent: 56),
                  _buildMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Partner Support',
                    subtitle: 'FAQs, ticket desk, live chat',
                    onTap: () => context.push('/profile/support'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Navigation Menu Card 3: System
            CooliCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.terminal_rounded,
                    title: 'API Live Hub & Network Logger',
                    subtitle: 'Test Dio endpoints, view models & console logs',
                    iconColor: AppColors.primaryBlue,
                    onTap: () => context.push('/api-hub'),
                  ),
                  const Divider(indent: 56),
                  _buildMenuItem(
                    icon: Icons.lock_outline_rounded,
                    title: 'Privacy & Security Policy',
                    onTap: () {},
                  ),
                  const Divider(indent: 56),
                  _buildMenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    titleColor: AppColors.error,
                    iconColor: AppColors.error,
                    showArrow: false,
                    onTap: () => _onLogout(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Color? iconColor,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primaryBlue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primaryBlue, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w700,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            )
          : null,
      trailing: showArrow
          ? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary)
          : null,
      onTap: onTap,
    );
  }
}
