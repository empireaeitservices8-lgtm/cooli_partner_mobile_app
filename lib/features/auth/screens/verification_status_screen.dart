import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/cooli_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/models.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/partner_provider.dart';
import '../../../providers/job_provider.dart';

class VerificationStatusScreen extends ConsumerStatefulWidget {
  final String? phoneNumber;

  const VerificationStatusScreen({
    super.key,
    this.phoneNumber,
  });

  @override
  ConsumerState<VerificationStatusScreen> createState() => _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends ConsumerState<VerificationStatusScreen> {
  bool _isChecking = false;
  bool _isCompleting = false;
  Partner? _partner;

  @override
  void initState() {
    super.initState();
    _loadPartner();
  }

  Future<void> _loadPartner() async {
    final phone = widget.phoneNumber ?? ref.read(authNotifierProvider).partner?.phone;
    if (phone != null && phone.isNotEmpty) {
      final p = await ref.read(authNotifierProvider.notifier).getPartnerByPhone(phone);
      if (mounted) {
        setState(() {
          _partner = p ?? ref.read(authNotifierProvider).partner;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _partner = ref.read(authNotifierProvider).partner;
        });
      }
    }
  }

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);

    // 1. Try real backend check-approval-status API first
    final approvalRes =
        await ref.read(authNotifierProvider.notifier).checkApprovalStatus();

    if (approvalRes != null && mounted) {
      setState(() => _isChecking = false);
      if (approvalRes.isApproved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Verification completed! Your account is approved.'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadPartner();
        context.go('/home');
        return;
      } else if (approvalRes.isRejected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Registration rejected by admin. Please contact support or upload valid documents.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Verification in progress. Compliance team is currently reviewing your documents.'),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
        return;
      }
    }

    // 2. Fallback to local repository check
    await Future.delayed(const Duration(milliseconds: 700));
    final phone = _partner?.phone ?? widget.phoneNumber ?? '';
    final isDone = await ref
        .read(authNotifierProvider.notifier)
        .isPhoneVerificationCompleted(phone);
    if (!mounted) return;
    setState(() => _isChecking = false);

    if (isDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Verification completed! Your account is active.'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadPartner();
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Verification in progress. Compliance team is currently reviewing your documents.'),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
    }
  }


  Future<void> _completeVerificationNow() async {
    setState(() => _isCompleting = true);
    final phone = _partner?.phone ?? widget.phoneNumber ?? '+91 98470 12345';
    final verified = await ref.read(authNotifierProvider.notifier).completeVerification(phone);
    if (!mounted) return;
    setState(() => _isCompleting = false);

    if (verified != null) {
      // Sync into active partner notifier and set job filter
      await ref.read(partnerNotifierProvider.notifier).switchPartner(verified);
      ref.read(jobsNotifierProvider.notifier).setFilter(verified.role.associatedJobType);

      setState(() {
        _partner = verified;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 56),
          title: const Text('Verification Approved!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800)),
          content: Text(
            'Congratulations ${verified.name}! Your ${verified.role.title} credentials and vehicle have been verified. You can now access your dashboard and start accepting jobs.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            CooliPrimaryButton(
              label: 'OPEN HOME DASHBOARD',
              icon: Icons.dashboard_rounded,
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/home');
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectivePartner = _partner ?? ref.watch(authNotifierProvider).partner;
    final isVerified = effectivePartner?.status == PartnerStatus.active;
    final role = effectivePartner?.role ?? PartnerRole.porter;

    return AppScaffold(
      header: BackHeader(
        title: 'Partner Verification',
        onBack: () => context.go('/login'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: AppColors.textPrimary),
            tooltip: 'Verification Support',
            onPressed: () => _showSupportModal(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.horizontalPadding(context),
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // Hero Status Banner Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isVerified
                    ? const LinearGradient(
                        colors: [Color(0xFF059669), Color(0xFF10B981)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isVerified ? Colors.green : Colors.amber).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isVerified ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isVerified ? 'Verification Approved & Active!' : 'Verification In Progress',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isVerified
                        ? 'Your partner account is 100% active. You can log in and accept bookings now.'
                        : 'Your application is under compliance review. Login to dashboard is enabled once approved.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isVerified ? 'STATUS: ACTIVE PARTNER' : 'ESTIMATED APPROVAL: 2 - 24 HOURS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Partner Profile Summary Card
            CooliCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_pin_rounded, color: AppColors.primaryBlue, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Application Details',
                            style: AppTextStyles.titleMedium.copyWith(fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      StatusBadge.verified(role.title),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildDetailRow('Partner Name', effectivePartner?.name ?? 'Registered Partner'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Mobile Number', effectivePartner?.phone ?? widget.phoneNumber ?? '—'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Partner ID', effectivePartner?.id ?? 'CP-PENDING'),
                  const SizedBox(height: 8),
                  _buildDetailRow('City / Operational Hub', effectivePartner?.city ?? 'Kochi / Kerala'),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Work Mode / Category',
                    role.description,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Verification Process Steps Tracker
            Text(
              'Verification Checklist',
              style: AppTextStyles.titleMedium.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),

            CooliCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStepTile(
                    stepNumber: '1',
                    title: 'Phone & OTP Authentication',
                    subtitle: 'Mobile number confirmed with 6-digit OTP',
                    isDone: true,
                    inProgress: false,
                  ),
                  const Divider(height: 20),
                  _buildStepTile(
                    stepNumber: '2',
                    title: 'Driving License & KYC Documents',
                    subtitle: 'Commercial badge & Aadhaar/PAN upload',
                    isDone: isVerified,
                    inProgress: !isVerified,
                  ),
                  const Divider(height: 20),
                  _buildStepTile(
                    stepNumber: '3',
                    title: 'Vehicle RC & Fitness (VAHAN API)',
                    subtitle: 'RTO registration & commercial insurance validated',
                    isDone: isVerified,
                    inProgress: !isVerified,
                  ),
                  const Divider(height: 20),
                  _buildStepTile(
                    stepNumber: '4',
                    title: 'Bank Account Payout Verification',
                    subtitle: '₹1 penny drop test & IFSC code verified',
                    isDone: true,
                    inProgress: false,
                  ),
                  const Divider(height: 20),
                  _buildStepTile(
                    stepNumber: '5',
                    title: 'Admin Background & Operations Clearance',
                    subtitle: isVerified ? 'Approved by COOLI Partner Operations' : 'Under compliance review',
                    isDone: isVerified,
                    inProgress: !isVerified,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (isVerified) ...[
              CooliPrimaryButton(
                label: 'ENTER HOME DASHBOARD',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  if (effectivePartner != null) {
                    ref.read(partnerNotifierProvider.notifier).switchPartner(effectivePartner);
                  }
                  context.go('/home');
                },
              ),
            ] else ...[
              // Fast testing instant approval button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isCompleting ? null : _completeVerificationNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: _isCompleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    _isCompleting ? 'Approving Verification...' : 'COMPLETE VERIFICATION (APPROVE NOW)',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              CooliSecondaryButton(
                label: _isChecking ? 'Checking...' : 'REFRESH STATUS',
                icon: Icons.refresh_rounded,
                onPressed: _checkStatus,
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Back to Login / Switch Phone'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
            ],

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildStepTile({
    required String stepNumber,
    required String title,
    required String subtitle,
    required bool isDone,
    required bool inProgress,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.success
                : (inProgress ? AppColors.warning : AppColors.surfaceMuted),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : (inProgress
                    ? const Icon(Icons.hourglass_bottom_rounded, color: Colors.white, size: 16)
                    : Text(
                        stepNumber,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      )),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDone ? AppColors.textPrimary : (inProgress ? const Color(0xFFB45309) : AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (isDone)
          StatusBadge.verified('Done')
        else if (inProgress)
          StatusBadge.pending('In Review')
        else
          const StatusBadge(label: 'Pending', type: BadgeType.neutral),
      ],
    );
  }

  void _showSupportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verification Support Desk', style: AppTextStyles.headline.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Need expedited verification or have questions regarding document submission? Contact our 24/7 partner team.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFDCFCE7),
                child: Icon(Icons.phone_rounded, color: AppColors.success),
              ),
              title: const Text('Partner Helpline (Toll-Free)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('1800-266-5472 (1800-COOLI)'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Calling Cooli Partner Desk at 1800-266-5472...')),
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE0E7FF),
                child: Icon(Icons.chat_rounded, color: AppColors.primaryBlue),
              ),
              title: const Text('WhatsApp Compliance Desk', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('+91 98470 00000 (Instant Chat)'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Connecting to Cooli Compliance WhatsApp...')),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
