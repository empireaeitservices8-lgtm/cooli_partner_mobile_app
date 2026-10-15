import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/cooli_card.dart';
import '../../../core/widgets/selection_widgets.dart';
import '../../../core/widgets/info_rows.dart';
import '../../../core/widgets/dialogs_and_sheets.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';

class EarningsDashboardScreen extends ConsumerStatefulWidget {
  const EarningsDashboardScreen({super.key});

  @override
  ConsumerState<EarningsDashboardScreen> createState() => _EarningsDashboardScreenState();
}

class _EarningsDashboardScreenState extends ConsumerState<EarningsDashboardScreen> {
  int _selectedTab = 0; // 0: Today, 1: This Week, 2: This Month
  final List<String> _periodTabs = const ['Today', 'This Week', 'This Month'];

  void _showTransactionDetails(EarningsTransaction txn) {
    CooliBottomSheet.show(
      context,
      title: 'Payout Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text('NET SETTLEMENT', style: AppTextStyles.captionBold.copyWith(color: AppColors.textTertiary)),
                const SizedBox(height: 4),
                Text(
                  '₹${txn.netAmount.toStringAsFixed(0)}',
                  style: AppTextStyles.numberDisplayLarge.copyWith(color: AppColors.primaryBlue),
                ),
                Text(
                  'Credited via ${txn.paymentMethod}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ),
          const Divider(height: 28),
          InfoRow(label: 'Trip Description', value: txn.title),
          InfoRow(label: 'Route & Metrics', value: txn.routeSummary),
          InfoRow(label: 'Date & Time', value: DateFormat('hh:mm a, dd MMM yyyy').format(txn.timestamp)),
          const Divider(height: 20),
          PriceRow(title: 'Gross Fare', amount: txn.grossAmount),
          PriceRow(title: 'Platform Fee', amount: txn.commissionAmount, isNegative: true),
          if (txn.tipAmount != null)
            PriceRow(title: 'Customer Tip', amount: txn.tipAmount!),
          const Divider(height: 20),
          PriceRow(title: 'Net Deposited', amount: txn.netAmount, isTotal: true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final earningsState = ref.watch(earningsNotifierProvider);
    final summary = earningsState.summary;
    final chartPoints = earningsState.chartPoints;
    final txns = earningsState.transactions;

    double displayAmount;
    if (_selectedTab == 0) {
      displayAmount = summary.todayEarnings;
    } else if (_selectedTab == 1) {
      displayAmount = summary.weekEarnings;
    } else {
      displayAmount = summary.monthEarnings;
    }

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Partner Earnings',
                    style: AppTextStyles.headline.copyWith(fontWeight: FontWeight.w900),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue),
                    onPressed: () => ref.read(earningsNotifierProvider.notifier).loadEarnings(),
                  ),
                ],
              ),
            ),

            // Time Frame Tabs (Today, This Week, This Month)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: TabSelector(
                tabs: _periodTabs,
                selectedIndex: _selectedTab,
                onTabSelected: (index) {
                  setState(() {
                    _selectedTab = index;
                  });
                },
              ),
            ),

            // Hero Earnings Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTab == 0
                              ? "TODAY'S NET REVENUE"
                              : _selectedTab == 1
                                  ? "WEEKLY NET EARNINGS"
                                  : "MONTHLY TOTAL PAYOUT",
                          style: AppTextStyles.captionBold.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 1.0,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Bank Auto-Settled',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '₹${displayAmount.toStringAsFixed(0)}',
                      style: AppTextStyles.numberDisplayLarge.copyWith(color: Colors.white, fontSize: 38),
                    ),
                    const SizedBox(height: 18),

                    // Quick Payout Action
                    CooliPrimaryButton(
                      label: 'REQUEST INSTANT WITHDRAWAL',
                      icon: Icons.account_balance_wallet_rounded,
                      backgroundColor: Colors.white,
                      textColor: AppColors.primaryBlue,
                      height: 48,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Instant UPI payout initiated to HDFC bank account!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 4 Key Metric Breakdowns (Gross, Commission, Bonuses, Net)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: CooliCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gross Sales', style: AppTextStyles.caption),
                          const SizedBox(height: 4),
                          Text('₹${summary.totalGross.toStringAsFixed(0)}', style: AppTextStyles.metricValue),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CooliCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Commission', style: AppTextStyles.caption),
                          const SizedBox(height: 4),
                          Text(
                            '-₹${summary.commissionDeducted.toStringAsFixed(0)}',
                            style: AppTextStyles.metricValue.copyWith(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: CooliCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Surge Bonuses', style: AppTextStyles.caption),
                          const SizedBox(height: 4),
                          Text(
                            '+₹${summary.bonuses.toStringAsFixed(0)}',
                            style: AppTextStyles.metricValue.copyWith(color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CooliCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Completed Trips', style: AppTextStyles.caption),
                          const SizedBox(height: 4),
                          Text('${summary.completedTrips}', style: AppTextStyles.metricValue),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Weekly Trend Bar Chart using fl_chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CooliCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily Earnings Chart',
                          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        Text(
                          'Peak: Fri (₹3,600)',
                          style: AppTextStyles.captionBold.copyWith(color: AppColors.primaryBlue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 4000,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => AppColors.textPrimary,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final point = chartPoints[groupIndex];
                                return BarTooltipItem(
                                  '${point.dayName}\n₹${point.amount.toInt()}',
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < chartPoints.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        chartPoints[index].dayName,
                                        style: AppTextStyles.captionBold.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(chartPoints.length, (index) {
                            final point = chartPoints[index];
                            final isHighlight = point.amount >= 3000;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: point.amount,
                                  color: isHighlight ? AppColors.accentOrange : AppColors.primaryBlue,
                                  width: 18,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Recent Transactions History List
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Recent Trip Settlements',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 17),
              ),
            ),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: txns.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final txn = txns[index];
                return CooliCard(
                  onTap: () => _showTransactionDetails(txn),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          txn.jobType == JobType.ride
                              ? Icons.local_taxi_rounded
                              : txn.jobType == JobType.porter
                                  ? Icons.inventory_2_rounded
                                  : Icons.local_shipping_rounded,
                          color: AppColors.primaryBlue,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              txn.title,
                              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${txn.routeSummary} · ${DateFormat('dd MMM').format(txn.timestamp)}',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+₹${txn.netAmount.toStringAsFixed(0)}',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            txn.paymentMethod,
                            style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
