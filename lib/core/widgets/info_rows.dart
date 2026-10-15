import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Clean Key-Value Info Row
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool isBold;
  final Widget? trailing;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.isBold = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: isBold
                ? AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? AppColors.textPrimary,
                  )
                : AppTextStyles.bodyMedium.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Fare breakdown line item (Base Fare, Distance, Commission, Net Earnings)
class PriceRow extends StatelessWidget {
  final String title;
  final double amount;
  final bool isNegative;
  final bool isTotal;
  final String? subtitle;

  const PriceRow({
    super.key,
    required this.title,
    required this.amount,
    this.isNegative = false,
    this.isTotal = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = '${isNegative ? '-' : ''}₹${amount.toStringAsFixed(0)}';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTotal ? 10.0 : 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: isTotal
                    ? AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)
                    : AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ],
            ],
          ),
          Text(
            formattedAmount,
            style: isTotal
                ? AppTextStyles.priceLarge.copyWith(
                    color: AppColors.primaryBlue,
                    fontSize: 22,
                  )
                : AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isNegative ? AppColors.error : AppColors.textPrimary,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Visual Route Indicator (Green Pickup -> Vertical Line -> Red Destination)
class RouteRow extends StatelessWidget {
  final String pickup;
  final String destination;
  final String? distanceText;
  final String? etaText;

  const RouteRow({
    super.key,
    required this.pickup,
    required this.destination,
    this.distanceText,
    this.etaText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(height: 3),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                Container(
                  width: 2,
                  height: 32,
                  color: AppColors.cardBorder,
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pickup,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    destination,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (distanceText != null || etaText != null) ...[
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (distanceText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        distanceText!,
                        style: AppTextStyles.captionBold.copyWith(fontSize: 11),
                      ),
                    ),
                  if (etaText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      etaText!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}
