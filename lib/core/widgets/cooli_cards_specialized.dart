import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../models/models.dart';
import 'cooli_card.dart';
import 'cooli_buttons.dart';
import 'status_badge.dart';
import 'info_rows.dart';
import 'illustrations.dart';
import 'selection_widgets.dart';

/// Interactive Job Card on Feed and Dashboard
class CooliJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onTap;

  const CooliJobCard({
    super.key,
    required this.job,
    required this.onAccept,
    this.onDecline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color typeBg;
    Color typeFg;
    IconData typeIcon;

    switch (job.type) {
      case JobType.ride:
        typeBg = AppColors.infoLight;
        typeFg = AppColors.primaryBlue;
        typeIcon = Icons.local_taxi_rounded;
        break;
      case JobType.porter:
        typeBg = const Color(0xFFFEF3C7);
        typeFg = const Color(0xFFB45309);
        typeIcon = Icons.inventory_2_rounded;
        break;
      case JobType.truck:
        typeBg = const Color(0xFFDCFCE7);
        typeFg = AppColors.success;
        typeIcon = Icons.local_shipping_rounded;
        break;
    }

    return CooliCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Type Badge + Gross Fare
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: typeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(typeIcon, size: 14, color: typeFg),
                    const SizedBox(width: 5),
                    Text(
                      job.typeLabel,
                      style: AppTextStyles.captionBold.copyWith(color: typeFg, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    '₹${job.netEarnings.toStringAsFixed(0)}',
                    style: AppTextStyles.priceLarge.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Earn',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Route row (Pickup to Destination)
          RouteRow(
            pickup: job.pickup.title.split(',').first,
            destination: job.destination.title.split(',').first,
            distanceText: '${job.distanceKm} km',
            etaText: '${job.estimatedMinutes} min',
          ),

          if (job.packageDetails != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                job.packageDetails!,
                style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              if (onDecline != null) ...[
                Expanded(
                  flex: 2,
                  child: CooliSecondaryButton(
                    label: 'DECLINE',
                    height: 44,
                    textColor: AppColors.textSecondary,
                    onPressed: onDecline,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: 3,
                child: CooliPrimaryButton(
                  label: 'ACCEPT',
                  height: 44,
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Large Earnings Card with Hero Gradient
class CooliEarningsCard extends StatelessWidget {
  final double totalEarnings;
  final double todayEarnings;
  final int completedTrips;
  final double onlineHours;
  final VoidCallback? onPayout;

  const CooliEarningsCard({
    super.key,
    required this.totalEarnings,
    required this.todayEarnings,
    required this.completedTrips,
    required this.onlineHours,
    this.onPayout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                "TODAY'S EARNINGS",
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
                child: const Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: Color(0xFF6EE7B7), size: 14),
                    SizedBox(width: 4),
                    Text(
                      '+14% vs yesterday',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${todayEarnings.toStringAsFixed(0)}',
            style: AppTextStyles.numberDisplayLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubMetric('$completedTrips', 'Trips Completed'),
                Container(height: 24, width: 1, color: Colors.white.withOpacity(0.2)),
                _buildSubMetric('${onlineHours.toStringAsFixed(1)}h', 'Online Hours'),
                Container(height: 24, width: 1, color: Colors.white.withOpacity(0.2)),
                _buildSubMetric('₹${totalEarnings.toStringAsFixed(0)}', 'Total Balance'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubMetric(String val, String title) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11),
        ),
      ],
    );
  }
}

/// Bid Card for Truck Marketplace and History
class CooliBidCard extends StatelessWidget {
  final Bid bid;
  final VoidCallback? onAcceptCounter;
  final VoidCallback? onRejectCounter;
  final VoidCallback? onCounterAgain;

  const CooliBidCard({
    super.key,
    required this.bid,
    this.onAcceptCounter,
    this.onRejectCounter,
    this.onCounterAgain,
  });

  @override
  Widget build(BuildContext context) {
    return CooliCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  bid.loadTitle,
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildBidBadge(bid.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            bid.routeSummary,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer Offer', style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(
                      '₹${bid.customerOfferedPrice.toStringAsFixed(0)}',
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Your Bid', style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(
                      '₹${bid.yourBidAmount.toStringAsFixed(0)}',
                      style: AppTextStyles.priceMedium.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (bid.status == BidStatus.counterOfferReceived && bid.counterOfferAmount != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentOrange.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Shipper Counter Offer:',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                      ),
                      Text(
                        '₹${bid.counterOfferAmount!.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF92400E), fontSize: 17),
                      ),
                    ],
                  ),
                  if (bid.counterNote != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      bid.counterNote!,
                      style: const TextStyle(color: Color(0xFF78350F), fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CooliSecondaryButton(
                    label: 'REJECT',
                    height: 40,
                    textColor: AppColors.error,
                    borderColor: AppColors.errorLight,
                    onPressed: onRejectCounter,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CooliSecondaryButton(
                    label: 'COUNTER',
                    height: 40,
                    textColor: AppColors.primaryBlue,
                    onPressed: onCounterAgain,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CooliPrimaryButton(
                    label: 'ACCEPT',
                    height: 40,
                    backgroundColor: AppColors.success,
                    onPressed: onAcceptCounter,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBidBadge(BidStatus status) {
    switch (status) {
      case BidStatus.active:
        return StatusBadge(label: 'Pending', type: BadgeType.info);
      case BidStatus.counterOfferReceived:
        return StatusBadge(label: 'Counter Offer', type: BadgeType.warning);
      case BidStatus.accepted:
        return StatusBadge.verified('Accepted');
      case BidStatus.rejected:
        return StatusBadge.rejected('Rejected');
      case BidStatus.expired:
        return StatusBadge.expired('Expired');
    }
  }
}

/// Vehicle Card (Tata Ace, Bolero, etc.)
class CooliVehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onViewDetails;
  final VoidCallback? onSetActive;

  const CooliVehicleCard({
    super.key,
    required this.vehicle,
    required this.onViewDetails,
    this.onSetActive,
  });

  @override
  Widget build(BuildContext context) {
    return CooliCard(
      onTap: onViewDetails,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VehicleIllustration(type: vehicle.type, size: 70),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        vehicle.makeModel,
                        style: AppTextStyles.titleMedium.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (vehicle.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: AppTextStyles.captionBold.copyWith(color: AppColors.success, fontSize: 10),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  vehicle.registrationNumber,
                  style: AppTextStyles.captionBold.copyWith(
                    color: AppColors.primaryBlue,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    AppChip(label: vehicle.capacity, icon: Icons.fitness_center_rounded),
                    const SizedBox(width: 6),
                    AppChip(label: vehicle.fuelType, icon: Icons.local_gas_station_rounded),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge.verified(
                      vehicle.verificationState == VehicleVerificationState.verified
                          ? 'Verified'
                          : 'Pending Review',
                    ),
                    GestureDetector(
                      onTap: onViewDetails,
                      child: Text(
                        'VIEW DETAILS →',
                        style: AppTextStyles.captionBold.copyWith(color: AppColors.primaryBlue, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Document Card (DL, RC, Insurance, etc.)
class CooliDocumentCard extends StatelessWidget {
  final PartnerDocument document;
  final VoidCallback onUploadOrView;

  const CooliDocumentCard({
    super.key,
    required this.document,
    required this.onUploadOrView,
  });

  @override
  Widget build(BuildContext context) {
    return CooliCard(
      onTap: onUploadOrView,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.description_outlined, color: AppColors.primaryBlue, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  document.title,
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  'No: ${document.documentNumber}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                if (document.expiryDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Expires: ${DateFormat('dd MMM yyyy').format(document.expiryDate!)}',
                    style: AppTextStyles.caption.copyWith(fontSize: 11, color: AppColors.textTertiary),
                  ),
                ],
              ],
            ),
          ),
          _buildStatus(document.status),
        ],
      ),
    );
  }

  Widget _buildStatus(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return StatusBadge.verified();
      case DocumentStatus.pending:
        return StatusBadge.pending();
      case DocumentStatus.expired:
        return StatusBadge.expired();
      case DocumentStatus.rejected:
        return StatusBadge.rejected();
    }
  }
}

/// Notification Item Card
class CooliNotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const CooliNotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CooliCard(
      onTap: onTap,
      backgroundColor: notification.isRead ? Colors.white : const Color(0xFFF0F7FF),
      border: Border.all(
        color: notification.isRead ? AppColors.cardBorder : AppColors.primaryBlue.withOpacity(0.3),
        width: 1,
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getCategoryBg(notification.category),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(notification.category),
              size: 20,
              color: _getCategoryFg(notification.category),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        notification.title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('hh:mm a · dd MMM').format(notification.timestamp),
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryBg(NotificationCategory c) {
    switch (c) {
      case NotificationCategory.payments:
        return const Color(0xFFDCFCE7);
      case NotificationCategory.jobs:
        return AppColors.infoLight;
      case NotificationCategory.documents:
        return const Color(0xFFFEF3C7);
      case NotificationCategory.promotions:
        return const Color(0xFFF3E8FF);
      case NotificationCategory.system:
        return AppColors.surfaceMuted;
    }
  }

  Color _getCategoryFg(NotificationCategory c) {
    switch (c) {
      case NotificationCategory.payments:
        return AppColors.success;
      case NotificationCategory.jobs:
        return AppColors.primaryBlue;
      case NotificationCategory.documents:
        return AppColors.accentOrangeDark;
      case NotificationCategory.promotions:
        return AppColors.secondaryPurple;
      case NotificationCategory.system:
        return AppColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(NotificationCategory c) {
    switch (c) {
      case NotificationCategory.payments:
        return Icons.account_balance_wallet_rounded;
      case NotificationCategory.jobs:
        return Icons.local_shipping_rounded;
      case NotificationCategory.documents:
        return Icons.verified_rounded;
      case NotificationCategory.promotions:
        return Icons.campaign_rounded;
      case NotificationCategory.system:
        return Icons.info_outline_rounded;
    }
  }
}

/// Truck Load Marketplace Card
class CooliLoadCard extends StatelessWidget {
  final TruckLoad load;
  final VoidCallback onAccept;
  final VoidCallback onBid;
  final VoidCallback? onTap;

  const CooliLoadCard({
    super.key,
    required this.load,
    required this.onAccept,
    required this.onBid,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CooliCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RealCargoImage(
                materialName: load.material,
                width: 56,
                height: 56,
                borderRadius: 12,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            load.material,
                            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '₹${load.customerOfferedPrice.toStringAsFixed(0)}',
                          style: AppTextStyles.priceLarge.copyWith(fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        AppChip(label: load.weightDescription, icon: Icons.scale_rounded),
                        const SizedBox(width: 6),
                        AppChip(label: load.vehicleRequired, icon: Icons.local_shipping_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          RouteRow(
            pickup: load.pickup.title.split(',').first,
            destination: load.destination.title.split(',').first,
            distanceText: '${load.distanceKm} km',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: CooliSecondaryButton(
                  label: 'BID',
                  height: 44,
                  icon: Icons.gavel_rounded,
                  onPressed: onBid,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CooliPrimaryButton(
                  label: 'ACCEPT',
                  height: 44,
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
