import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

enum BadgeType {
  success,
  warning,
  error,
  info,
  neutral,
}

/// Universal Status Badge for Jobs, Documents, Vehicles, and Verification
class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = BadgeType.neutral,
    this.icon,
    this.isCompact = false,
  });

  factory StatusBadge.verified([String label = 'Verified']) => StatusBadge(
        label: label,
        type: BadgeType.success,
        icon: Icons.check_circle_rounded,
      );

  factory StatusBadge.pending([String label = 'Pending']) => StatusBadge(
        label: label,
        type: BadgeType.warning,
        icon: Icons.access_time_filled_rounded,
      );

  factory StatusBadge.expired([String label = 'Expired']) => StatusBadge(
        label: label,
        type: BadgeType.error,
        icon: Icons.warning_rounded,
      );

  factory StatusBadge.rejected([String label = 'Rejected']) => StatusBadge(
        label: label,
        type: BadgeType.error,
        icon: Icons.cancel_rounded,
      );

  factory StatusBadge.online() => const StatusBadge(
        label: 'ONLINE',
        type: BadgeType.success,
        icon: Icons.circle,
      );

  factory StatusBadge.offline() => const StatusBadge(
        label: 'OFFLINE',
        type: BadgeType.neutral,
        icon: Icons.circle_outlined,
      );

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case BadgeType.success:
        bg = AppColors.successLight;
        fg = AppColors.success;
        break;
      case BadgeType.warning:
        bg = AppColors.warningLight;
        fg = const Color(0xFFB45309);
        break;
      case BadgeType.error:
        bg = AppColors.errorLight;
        fg = AppColors.error;
        break;
      case BadgeType.info:
        bg = AppColors.infoLight;
        fg = AppColors.info;
        break;
      case BadgeType.neutral:
        bg = AppColors.surfaceMuted;
        fg = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8.0 : 10.0,
        vertical: isCompact ? 3.0 : 5.0,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppSpacing.badgeRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isCompact ? 12 : 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: isCompact ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Driver Rating Display and Interactive Picker
class RatingWidget extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final bool showStarIcon;
  final double iconSize;

  const RatingWidget({
    super.key,
    required this.rating,
    this.reviewCount,
    this.showStarIcon = true,
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showStarIcon) ...[
            Icon(Icons.star_rounded, color: const Color(0xFFD97706), size: iconSize),
            const SizedBox(width: 3),
          ],
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFFB45309),
            ),
          ),
          if (reviewCount != null) ...[
            const SizedBox(width: 2),
            Text(
              ' ($reviewCount)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
