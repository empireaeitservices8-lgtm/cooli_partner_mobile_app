import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TimelineStepItem {
  final String title;
  final String? subtitle;
  final bool isCompleted;
  final bool isCurrent;

  const TimelineStepItem({
    required this.title,
    this.subtitle,
    required this.isCompleted,
    required this.isCurrent,
  });
}

/// Visual Step-by-Step Delivery & Trip Timeline
class TimelineWidget extends StatelessWidget {
  final List<TimelineStepItem> steps;

  const TimelineWidget({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                // Step Circle
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.isCompleted
                        ? AppColors.success
                        : step.isCurrent
                            ? AppColors.primaryBlue
                            : Colors.white,
                    border: Border.all(
                      color: step.isCompleted
                          ? AppColors.success
                          : step.isCurrent
                              ? AppColors.primaryBlue
                              : AppColors.cardBorder,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: step.isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : step.isCurrent
                            ? Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                  ),
                ),
                // Connector Line
                if (!isLast)
                  Container(
                    width: 2,
                    height: 36,
                    color: step.isCompleted ? AppColors.success : AppColors.cardBorder,
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0, bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: step.isCurrent || step.isCompleted ? FontWeight.w700 : FontWeight.w500,
                        color: step.isCurrent
                            ? AppColors.primaryBlue
                            : step.isCompleted
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                      ),
                    ),
                    if (step.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        step.subtitle!,
                        style: AppTextStyles.caption.copyWith(
                          color: step.isCurrent ? AppColors.primaryBlue : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
