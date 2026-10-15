import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/cooli_card.dart';
import '../../../core/widgets/cooli_text_fields.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';

class TruckBidScreen extends ConsumerStatefulWidget {
  final TruckLoad load;

  const TruckBidScreen({super.key, required this.load});

  @override
  ConsumerState<TruckBidScreen> createState() => _TruckBidScreenState();
}

class _TruckBidScreenState extends ConsumerState<TruckBidScreen> {
  late final TextEditingController _bidController;
  bool _isSubmitted = false;
  double _submittedBidAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _bidController = TextEditingController(
      text: widget.load.suggestedPrice.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  void _submitBid() async {
    final entered = double.tryParse(_bidController.text.trim());
    if (entered == null || entered <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid bid amount.')),
      );
      return;
    }

    final success = await ref.read(truckNotifierProvider.notifier).submitBid(
          load: widget.load,
          yourBidAmount: entered,
        );

    if (success && mounted) {
      setState(() {
        _isSubmitted = true;
        _submittedBidAmount = entered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return AppScaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 50),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bid Submitted ✓',
                  style: AppTextStyles.headline.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${_submittedBidAmount.toStringAsFixed(0)}',
                  style: AppTextStyles.numberDisplayLarge.copyWith(color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 8),
                Text(
                  'Waiting for shipper confirmation or counter offer...',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CooliPrimaryButton(
                  label: 'VIEW MY BIDS',
                  onPressed: () {
                    context.pushReplacement('/truck/bids');
                  },
                ),
                const SizedBox(height: 12),
                CooliSecondaryButton(
                  label: 'BACK TO MARKETPLACE',
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppScaffold(
      header: BackHeader(
        title: 'Submit Price Bid',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Load Summary Header Card
            CooliCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.load.material,
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.load.pickup.title.split(',').first} → ${widget.load.destination.title.split(',').first} (${widget.load.distanceKm} km)',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Market Comparison Matrix
            Row(
              children: [
                Expanded(
                  child: CooliCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer Offer', style: AppTextStyles.caption),
                        const SizedBox(height: 4),
                        Text(
                          '₹${widget.load.customerOfferedPrice.toStringAsFixed(0)}',
                          style: AppTextStyles.metricValue.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CooliCard(
                    backgroundColor: const Color(0xFFEFF6FF),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Suggested Fair Rate', style: AppTextStyles.caption.copyWith(color: AppColors.primaryBlue)),
                        const SizedBox(height: 4),
                        Text(
                          '₹${widget.load.suggestedPrice.toStringAsFixed(0)}',
                          style: AppTextStyles.metricValue.copyWith(fontSize: 20, color: AppColors.primaryBlue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Bid Amount Input
            Text(
              'Your Bid Amount (₹)',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            CooliTextField(
              controller: _bidController,
              hintText: 'Enter your quote amount',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.currency_rupee_rounded, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 16),

            // Quick increment chips (+100, +200, +500)
            Text(
              'Quick Adjustments',
              style: AppTextStyles.captionBold.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [100, 200, 500].map((increment) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text('+₹$increment'),
                    onPressed: () {
                      final curr = double.tryParse(_bidController.text.trim()) ?? widget.load.suggestedPrice;
                      setState(() {
                        _bidController.text = (curr + increment).toStringAsFixed(0);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 36),

            CooliPrimaryButton(
              label: 'SUBMIT BID TO SHIPPER',
              icon: Icons.send_rounded,
              onPressed: _submitBid,
            ),
          ],
        ),
      ),
    );
  }
}
