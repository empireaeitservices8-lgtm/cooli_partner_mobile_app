import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/cooli_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../services/mock_data.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = MockData.ratingSummary;
    final reviews = MockData.recentReviews;

    return AppScaffold(
      header: BackHeader(
        title: 'Ratings & Reviews',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Score & Distribution Card
            CooliCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Overall Big Score
                  Column(
                    children: [
                      Text(
                        summary.overallRating.toStringAsFixed(2),
                        style: AppTextStyles.numberDisplayLarge.copyWith(fontSize: 44, color: AppColors.primaryBlue),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (_) {
                          return const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18);
                        }),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${summary.totalReviews} total ratings',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),

                  // Horizontal Star Distribution Bars
                  Expanded(
                    child: Column(
                      children: [5, 4, 3, 2, 1].map((star) {
                        final count = summary.starCounts[star] ?? 0;
                        final percent = count / summary.totalReviews;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              Text('$star★', style: AppTextStyles.captionBold.copyWith(fontSize: 11)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percent,
                                    minHeight: 6,
                                    backgroundColor: AppColors.surfaceMuted,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 28,
                                child: Text(
                                  '$count',
                                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Recent Customer Feedback',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final rev = reviews[index];
                return CooliCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.infoLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    rev.customerName[0],
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(rev.customerName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                                  Text(
                                    DateFormat('dd MMM yyyy').format(rev.date),
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          RatingWidget(rating: rev.rating),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '"${rev.comment}"',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontStyle: FontStyle.italic),
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
