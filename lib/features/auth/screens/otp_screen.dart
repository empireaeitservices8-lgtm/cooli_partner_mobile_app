import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/cooli_text_fields.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/partner_provider.dart';
import '../../../providers/job_provider.dart';
import '../../../models/models.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _enteredOtp = '';
  int _secondsRemaining = AppConstants.otpResendCountdownSeconds;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = AppConstants.otpResendCountdownSeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onVerify() async {
    if (_enteredOtp.length < 6) {
      setState(() {
        _errorMessage = 'Please enter the complete 6-digit OTP';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    final success =
        await ref.read(authNotifierProvider.notifier).verifyOtp(_enteredOtp);
    if (success && mounted) {
      // Check if phone number is registered
      final isRegistered = await ref
          .read(authNotifierProvider.notifier)
          .isPhoneRegistered(widget.phoneNumber);

      if (isRegistered) {
        // Registered partner -> Go to Role/User Selection page
        final partner = await ref
            .read(authNotifierProvider.notifier)
            .getPartnerByPhone(widget.phoneNumber);
        if (partner != null && mounted) {
          await ref
              .read(partnerNotifierProvider.notifier)
              .switchPartner(partner);
          ref
              .read(jobsNotifierProvider.notifier)
              .setFilter(partner.role.associatedJobType);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP Verified! Welcome back, select your category.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 1),
          ),
        );
        context.go('/select-role');
      } else {
        // Not registered -> Go to Register page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('OTP Verified! Please complete registration to continue.'),
            backgroundColor: AppColors.primaryBlue,
            duration: Duration(seconds: 2),
          ),
        );
        context.go('/register');
      }
    } else if (mounted) {
      setState(() {
        _errorMessage = ref.read(authNotifierProvider).errorMessage ??
            'Invalid OTP. Please enter 123456';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return AppScaffold(
      header: BackHeader(
        title: 'Verify Phone',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Verification Code',
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium,
                children: [
                  const TextSpan(text: 'We sent a 6-digit SMS code to '),
                  TextSpan(
                    text: widget.phoneNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => context.pop(),
              child: Text(
                'Change Phone Number',
                style: AppTextStyles.captionBold
                    .copyWith(color: AppColors.primaryBlue),
              ),
            ),
            const SizedBox(height: 32),

            // 6-Digit Otp Field Component
            OtpField(
              length: 6,
              onChanged: (val) {
                setState(() {
                  _enteredOtp = val;
                  _errorMessage = null;
                });
              },
              onCompleted: (val) {
                setState(() {
                  _enteredOtp = val;
                });
                _onVerify();
              },
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.error, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.captionBold
                          .copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // OTP Helper Info Card
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            //   decoration: BoxDecoration(
            //     color: AppColors.surfaceMuted,
            //     borderRadius: BorderRadius.circular(12),
            //     border: Border.all(color: AppColors.cardBorder),
            //   ),
            //   child: Row(
            //     children: [
            //       const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
            //       const SizedBox(width: 8),
            //       Expanded(
            //         child: Text(
            //           'Development Mode OTP: ${AppConstants.mockOtp}',
            //           style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            const SizedBox(height: 24),

            // Primary Verification Button
            CooliPrimaryButton(
              label: 'VERIFY',
              icon: Icons.arrow_forward_rounded,
              isLoading: authState.isLoading,
              onPressed: _onVerify,
            ),

            const SizedBox(height: 16),

            // Resend countdown
            Center(
              child: _secondsRemaining > 0
                  ? Text(
                      'Resend OTP in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textTertiary),
                    )
                  : TextButton(
                      onPressed: () {
                        _startCountdown();
                        ref
                            .read(authNotifierProvider.notifier)
                            .sendOtp(widget.phoneNumber);
                      },
                      child: Text(
                        'RESEND OTP',
                        style: AppTextStyles.captionBold.copyWith(
                          color: AppColors.primaryBlue,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
