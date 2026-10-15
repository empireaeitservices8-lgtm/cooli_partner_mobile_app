import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/cooli_card.dart';
import '../../../core/widgets/info_rows.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../services/mock_data.dart';

class BankAccountScreen extends ConsumerWidget {
  const BankAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const bankAccount = MockData.primaryBankAccount;

    return AppScaffold(
      header: BackHeader(
        title: 'Settlement Account',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bank Card Visual Display
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        bankAccount.bankName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Icon(Icons.contactless_rounded, color: Colors.white70, size: 28),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    bankAccount.accountNumber, // Masked: •••• 4521
                    style: AppTextStyles.numberDisplayLarge.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                      letterSpacing: 4.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ACCOUNT HOLDER', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(bankAccount.accountHolderName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('IFSC CODE', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(bankAccount.ifscCode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Account Details Card
            CooliCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Verification Status', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 16)),
                      StatusBadge.verified('Verified Bank Account'),
                    ],
                  ),
                  const Divider(height: 24),
                  InfoRow(label: 'Bank Entity', value: bankAccount.bankName),
                  InfoRow(label: 'Account Holder', value: bankAccount.accountHolderName),
                  InfoRow(label: 'Account Number', value: bankAccount.accountNumber),
                  InfoRow(label: 'NEFT / RTGS IFSC', value: bankAccount.ifscCode),
                  InfoRow(label: 'Auto Payout Cycle', value: 'Daily 11:30 PM (T+0)'),
                ],
              ),
            ),
            const SizedBox(height: 28),

            CooliPrimaryButton(
              label: 'TEST PENNY DROP VERIFICATION',
              icon: Icons.check_circle_outline_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('₹1.00 test deposit verified successfully via NPCI UPI!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            CooliSecondaryButton(
              label: 'EDIT OR CHANGE BANK ACCOUNT',
              icon: Icons.edit_outlined,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please contact support desk for changing primary settlement account.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
