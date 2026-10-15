import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/cooli_card.dart';
import '../../../core/widgets/cooli_text_fields.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _faqs = [
    {
      'q': 'How are weekly and daily earnings settled?',
      'a': 'Your net trip earnings are automatically transferred directly to your verified bank account daily at 11:30 PM with zero transfer fees.',
    },
    {
      'q': 'How does truck freight bidding work?',
      'a': 'Shippers post loads with customer offered prices. You can accept immediately or submit a competitive counter-bid. If the shipper counters back, you can accept, counter again, or decline.',
    },
    {
      'q': 'What happens if a customer cancels an active trip?',
      'a': 'If a customer cancels after you have arrived at the pickup location or completed more than 5 minutes of transit towards them, a standard cancellation compensation is automatically credited to your wallet.',
    },
    {
      'q': 'How do I renew expired vehicle insurance or FC?',
      'a': 'Navigate to Documents > Select Vehicle Insurance > Tap Update and upload a clear photograph of your renewed policy document.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: BackHeader(
        title: 'Partner Help Center',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            SearchField(
              controller: _searchController,
              hintText: 'Search queries, tickets or FAQs...',
            ),
            const SizedBox(height: 20),

            // Emergency / Quick Contact Cards
            Row(
              children: [
                Expanded(
                  child: CooliCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dialing COOLI Partner Desk: 1800 200 4567')),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone_in_talk_rounded, color: AppColors.success, size: 20),
                        ),
                        const SizedBox(height: 10),
                        Text('Call Support', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
                        Text('Toll-Free 24/7', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CooliCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Starting live partner agent chat...')),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.infoLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chat_rounded, color: AppColors.primaryBlue, size: 20),
                        ),
                        const SizedBox(height: 10),
                        Text('Live Agent Chat', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
                        Text('Instant reply', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Help Topics Category Matrix
            Text(
              'Browse by Category',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildCategoryPill('Account & Login', Icons.person_outline_rounded),
                _buildCategoryPill('Trips & Rides', Icons.local_taxi_rounded),
                _buildCategoryPill('Porter Deliveries', Icons.inventory_2_rounded),
                _buildCategoryPill('Truck Bidding', Icons.local_shipping_rounded),
                _buildCategoryPill('Payments & UPI', Icons.account_balance_wallet_rounded),
                _buildCategoryPill('Documents & Permits', Icons.description_outlined),
              ],
            ),
            const SizedBox(height: 28),

            // Frequently Asked Questions
            Text(
              'Frequently Asked Questions',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                return CooliCard(
                  padding: const EdgeInsets.all(14),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    shape: const Border(),
                    title: Text(
                      faq['q']!,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          faq['a']!,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // Submit Ticket Action
            CooliCard(
              backgroundColor: const Color(0xFFEFF6FF),
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Text(
                    'Need specialized help from operations?',
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Raise a support ticket and our operations manager will call back within 15 minutes.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  CooliPrimaryButton(
                    label: 'CREATE SUPPORT TICKET',
                    icon: Icons.confirmation_number_outlined,
                    height: 48,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ticket created: TCK-99120. Operations desk notified.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
