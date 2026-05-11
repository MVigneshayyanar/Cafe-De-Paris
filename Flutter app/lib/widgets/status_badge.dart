import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/table_model.dart';
import '../models/order.dart';

/// Reusable status badge pill widget matching the exact design system colors.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  /// Factory for table status badges
  factory StatusBadge.fromTableStatus(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return const StatusBadge(
          label: 'Available',
          backgroundColor: AppColors.availableBg,
          textColor: AppColors.availableText,
        );
      case TableStatus.ordered:
        return const StatusBadge(
          label: 'Ordered',
          backgroundColor: AppColors.orderingBg,
          textColor: AppColors.orderingText,
        );
      case TableStatus.preparing:
        return const StatusBadge(
          label: 'Preparing',
          backgroundColor: AppColors.preparingBg,
          textColor: AppColors.preparingText,
        );
      case TableStatus.ready:
        return const StatusBadge(
          label: 'Ready',
          backgroundColor: AppColors.readyBg,
          textColor: AppColors.readyText,
        );
      case TableStatus.eating:
        return const StatusBadge(
          label: 'Eating',
          backgroundColor: AppColors.eatingBg,
          textColor: AppColors.eatingText,
        );
      case TableStatus.billing:
        return const StatusBadge(
          label: 'Billing',
          backgroundColor: AppColors.billingBg,
          textColor: AppColors.billingText,
        );
      case TableStatus.billed:
        return const StatusBadge(
          label: 'Billed',
          backgroundColor: AppColors.billedBg,
          textColor: AppColors.billedText,
        );
    }
  }

  /// Factory for order status badges
  factory StatusBadge.fromOrderStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return const StatusBadge(
          label: 'New Order',
          backgroundColor: AppColors.cardSurface,
          textColor: AppColors.textSecondary,
        );
      case OrderStatus.ready:
        return const StatusBadge(
          label: 'Ready to Serve',
          backgroundColor: AppColors.readyBg,
          textColor: AppColors.readyText,
        );
      case OrderStatus.preparing:
        return const StatusBadge(
          label: 'Preparing',
          backgroundColor: AppColors.preparingBg,
          textColor: AppColors.preparingText,
        );
      case OrderStatus.served:
        return const StatusBadge(
          label: 'Served',
          backgroundColor: AppColors.availableBg,
          textColor: AppColors.availableText,
        );
      case OrderStatus.awaitingPayment:
        return StatusBadge(
          label: 'Awaiting Payment',
          backgroundColor: AppColors.errorRed.withValues(alpha: 0.1),
          textColor: AppColors.errorRed,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.badgeRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
