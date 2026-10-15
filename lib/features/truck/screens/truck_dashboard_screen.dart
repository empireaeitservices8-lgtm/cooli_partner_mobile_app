import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/cooli_cards_specialized.dart';
import '../../../core/widgets/state_views.dart';
import '../../../providers/providers.dart';

class TruckDashboardScreen extends ConsumerWidget {
  const TruckDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final truckState = ref.watch(truckNotifierProvider);
    final loads = truckState.loads;

    return AppScaffold(
      header: BackHeader(
        title: 'Truck Freight Marketplace',
        onBack: () => context.pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.primaryBlue),
            tooltip: 'My Bids & Counters',
            onPressed: () => context.push('/truck/bids'),
          ),
        ],
      ),
      body: truckState.isLoading
          ? const LoadingState(message: 'Loading freight loads...')
          : loads.isEmpty
              ? const EmptyState(
                  icon: Icons.local_shipping_outlined,
                  title: 'No Active Freight Loads',
                  message: 'Currently no shippers have open bidding requests for your vehicle capacity.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: loads.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final load = loads[index];
                    return CooliLoadCard(
                      load: load,
                      onTap: () {
                        context.push('/truck/details', extra: load);
                      },
                      onAccept: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Accepted load for ${load.material} at ₹${load.customerOfferedPrice.toInt()}!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      onBid: () {
                        context.push('/truck/bid', extra: load);
                      },
                    );
                  },
                ),
    );
  }
}
