import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/selection_widgets.dart';
import '../../../core/widgets/cooli_cards_specialized.dart';
import '../../../core/widgets/cooli_text_fields.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';

class TruckBidsHistoryScreen extends ConsumerStatefulWidget {
  const TruckBidsHistoryScreen({super.key});

  @override
  ConsumerState<TruckBidsHistoryScreen> createState() => _TruckBidsHistoryScreenState();
}

class _TruckBidsHistoryScreenState extends ConsumerState<TruckBidsHistoryScreen> {
  BidStatus? _selectedStatusFilter;

  void _showCounterDialog(Bid bid) {
    final counterController = TextEditingController(
      text: ((bid.counterOfferAmount ?? bid.yourBidAmount) + 100).toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Counter Back to Shipper', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter your counter proposal for ${bid.loadTitle}:', style: AppTextStyles.bodySmall),
            const SizedBox(height: 16),
            CooliTextField(
              controller: counterController,
              hintText: 'Counter amount in ₹',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.currency_rupee_rounded, color: AppColors.primaryBlue),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final newAmount = double.tryParse(counterController.text.trim());
              if (newAmount != null) {
                ref.read(truckNotifierProvider.notifier).counterAgain(bid.id, newAmount);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Counter offer of ₹${newAmount.toInt()} sent!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: const Text('SEND COUNTER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final truckState = ref.watch(truckNotifierProvider);
    final allBids = truckState.bids;

    final filteredBids = _selectedStatusFilter == null
        ? allBids
        : allBids.where((b) => b.status == _selectedStatusFilter).toList();

    return AppScaffold(
      header: BackHeader(
        title: 'Bids & Counter Offers',
        onBack: () => context.pop(),
      ),
      body: Column(
        children: [
          // Filter Chips (All, Active, Countered, Accepted, Rejected)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                FilterChipWidget(
                  label: 'All Bids',
                  isSelected: _selectedStatusFilter == null,
                  onTap: () => setState(() => _selectedStatusFilter = null),
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: 'Counter Received',
                  isSelected: _selectedStatusFilter == BidStatus.counterOfferReceived,
                  onTap: () => setState(() => _selectedStatusFilter = BidStatus.counterOfferReceived),
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: 'Active Pending',
                  isSelected: _selectedStatusFilter == BidStatus.active,
                  onTap: () => setState(() => _selectedStatusFilter = BidStatus.active),
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: 'Accepted',
                  isSelected: _selectedStatusFilter == BidStatus.accepted,
                  onTap: () => setState(() => _selectedStatusFilter = BidStatus.accepted),
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: 'Rejected',
                  isSelected: _selectedStatusFilter == BidStatus.rejected,
                  onTap: () => setState(() => _selectedStatusFilter = BidStatus.rejected),
                ),
              ],
            ),
          ),

          // Bid Cards List
          Expanded(
            child: filteredBids.isEmpty
                ? const EmptyState(
                    icon: Icons.gavel_outlined,
                    title: 'No Bids Found',
                    message: 'You have no bidding records under this filter.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    itemCount: filteredBids.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filteredBids[index];
                      return CooliBidCard(
                        bid: item,
                        onAcceptCounter: () {
                          ref.read(truckNotifierProvider.notifier).acceptCounterOffer(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Counter offer accepted! Load confirmed for your vehicle.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        onRejectCounter: () {
                          ref.read(truckNotifierProvider.notifier).rejectCounterOffer(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Counter offer rejected.')),
                          );
                        },
                        onCounterAgain: () => _showCounterDialog(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
