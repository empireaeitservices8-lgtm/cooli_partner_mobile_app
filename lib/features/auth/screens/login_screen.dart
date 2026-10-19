import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/cooli_text_fields.dart';
import '../../../core/widgets/backgrounds.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onContinue() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      setState(() {
        _errorText = 'Please enter a valid 10-digit mobile number';
      });
      return;
    }

    setState(() {
      _errorText = null;
    });

    final formatted = '+91 $phone';
    final success = await ref.read(authNotifierProvider.notifier).sendOtp(formatted);
    if (success && mounted) {
      context.push('/otp', extra: formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return AppScaffold(
      body: Stack(
        children: [
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CityIllustrationBackground(height: 90),
          ),
          Positioned(
            top: 12,
            right: 16,
            child: InkWell(
              onTap: () => context.push('/api-hub'),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryYellow.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.terminal_rounded, size: 14, color: AppColors.primaryYellow),
                    const SizedBox(width: 5),
                    const Text(
                      'API Hub & Logs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Logo & Header
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: AppColors.primaryGlow,
                    ),
                    child: const Center(
                      child: Icon(Icons.local_shipping_rounded, color: Colors.white, size: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    AppConstants.appName,
                    style: AppTextStyles.headline.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Partner Login',
                    style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 40),

                Text(
                  'Enter Mobile Number',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  "We will send a 6-digit verification code to verify your partner profile.",
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Phone Input with Country Code prefix
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 6),
                          Text(
                            '+91',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CooliTextField(
                        controller: _phoneController,
                        hintText: '98470 12345',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        errorText: _errorText,
                        onSubmitted: (_) => _onContinue(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                CooliPrimaryButton(
                  label: 'CONTINUE',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: authState.isLoading,
                  onPressed: _onContinue,
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'By continuing, you agree to the COOLI Partner Terms of Service & Privacy Policy.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
