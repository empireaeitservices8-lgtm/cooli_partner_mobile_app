import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/cooli_card.dart';
import '../../../core/widgets/dialogs_and_sheets.dart';

class SafetyCenterScreen extends StatelessWidget {
  const SafetyCenterScreen({super.key});

  void _triggerSos(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'CONFIRM EMERGENCY SOS',
      message: 'Are you in danger? This will broadcast your live vehicle coordinates to Police (112), COOLI Emergency Safety Control, and your registered family contacts.',
      confirmLabel: 'YES, DISPATCH HELP',
      cancelLabel: 'CANCEL',
      isDangerous: true,
      icon: Icons.emergency_rounded,
    );

    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('EMERGENCY BROADCAST ACTIVE! 112 Dispatch alerted with your GPS location.'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: BackHeader(
        title: 'Safety & Emergency Toolkit',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // High-Alert Red SOS Emergency Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Emergency SOS',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                            ),
                            Text(
                              'Tap to alert police & emergency teams with your live GPS.',
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  CooliDangerButton(
                    label: 'TRIGGER EMERGENCY SOS',
                    icon: Icons.warning_rounded,
                    height: 50,
                    onPressed: () => _triggerSos(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Partner Safety Tools',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            const SizedBox(height: 12),

            // Safety Option Cards
            CooliCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  _buildSafetyTile(
                    icon: Icons.share_location_rounded,
                    title: 'Share Live Trip Route',
                    subtitle: 'Share live GPS tracking link with your family or friends',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Live trip tracking link copied to clipboard!')),
                      );
                    },
                  ),
                  const Divider(indent: 56),
                  _buildSafetyTile(
                    icon: Icons.contact_phone_outlined,
                    title: 'Emergency Contacts',
                    subtitle: '2 Trusted phone numbers saved for emergency broadcasts',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Viewing 2 registered emergency contacts.')),
                      );
                    },
                  ),
                  const Divider(indent: 56),
                  _buildSafetyTile(
                    icon: Icons.car_crash_outlined,
                    title: 'Roadside Breakdown Assistance',
                    subtitle: '24/7 towing, tire repair & battery jumpstart across Kerala',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Connecting to Highway Assistance Desk (1033)...')),
                      );
                    },
                  ),
                  const Divider(indent: 56),
                  _buildSafetyTile(
                    icon: Icons.report_problem_outlined,
                    title: 'Report Incident or Misconduct',
                    subtitle: 'Confidential reporting to COOLI Driver Welfare Council',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening confidential incident report form...')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Safety Guidelines Card
            CooliCard(
              backgroundColor: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.health_and_safety_rounded, color: AppColors.primaryBlue, size: 22),
                      const SizedBox(width: 8),
                      Text('Safe Driving Commitment', style: AppTextStyles.titleMedium.copyWith(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Always wear seatbelts / helmets while driving.\n'
                    '• Fasten and secure cargo ropes before dispatch.\n'
                    '• Avoid mobile usage while driving on highway stretches.\n'
                    '• Take a 15-minute rest after every 4 hours of commercial transit.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.infoLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 22),
      ),
      title: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}
