import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Driver Online / Offline Toggle Banner and Button
class OnlineStatusToggle extends StatelessWidget {
  final bool isOnline;
  final ValueChanged<bool> onToggle;

  const OnlineStatusToggle({
    super.key,
    required this.isOnline,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOnline ? const Color(0xFF86EFAC) : AppColors.cardBorder,
          width: 1.5,
        ),
        boxShadow: isOnline
            ? [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ]
            : null,
      ),
      child: Row(
        children: [
          // Glowing status indicator dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? AppColors.success : AppColors.textTertiary,
              boxShadow: isOnline
                  ? [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.6),
                        blurRadius: 6,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isOnline ? 'YOU ARE ONLINE' : 'YOU ARE OFFLINE',
                  style: AppTextStyles.captionBold.copyWith(
                    color: isOnline ? const Color(0xFF15803D) : AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  isOnline ? 'Receiving trips & logistics loads' : 'Go online to receive opportunities',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: isOnline ? const Color(0xFF166534) : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isOnline,
            activeColor: Colors.white,
            activeTrackColor: AppColors.success,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.textTertiary,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
