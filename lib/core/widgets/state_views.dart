import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'cooli_buttons.dart';

/// Clean Empty State screen with icon, title, message, and action
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  factory EmptyState.noJobs({VoidCallback? onGoOnline}) => EmptyState(
        icon: Icons.work_off_outlined,
        title: 'No Jobs Available',
        message: 'Stay online and move closer to high-demand logistics hubs to receive opportunities.',
        actionLabel: onGoOnline != null ? 'Check Online Status' : null,
        onAction: onGoOnline,
      );

  factory EmptyState.noVehicles({VoidCallback? onAddVehicle}) => EmptyState(
        icon: Icons.local_shipping_outlined,
        title: 'No Vehicles Added',
        message: 'Add your commercial vehicle to start accepting freight, porter, and ride assignments.',
        actionLabel: onAddVehicle != null ? 'Add Vehicle Now' : null,
        onAction: onAddVehicle,
      );

  factory EmptyState.noEarnings() => const EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'No Earnings Yet',
        message: 'Complete your first trip today to start accumulating your daily payout.',
      );

  factory EmptyState.noNotifications() => const EmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'All Caught Up!',
        message: 'You have no new alerts, ride notifications, or bidding counter offers.',
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              CooliPrimaryButton(
                label: actionLabel!,
                onPressed: onAction!,
                height: 48,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Polished Loading State with brand indicator and helper label
class LoadingState extends StatelessWidget {
  final String message;

  const LoadingState({
    super.key,
    this.message = 'Loading COOLI Partner...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Friendly Error State with retry button
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    this.title = 'Unable to Load Data',
    this.message = 'Something went wrong while communicating with the server. Please check your network.',
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 44, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CooliSecondaryButton(
              label: 'Try Again',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
}
