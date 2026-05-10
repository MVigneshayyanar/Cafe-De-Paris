import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../models/order.dart';

/// Order card widget for Service screen
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onMarkServed;
  const OrderCard({super.key, required this.order, this.onMarkServed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FaIcon(FontAwesomeIcons.clipboardList, size: 16, color: AppColors.primaryTeal),
              const SizedBox(width: 8),
              Text(order.tableName, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 6),
          Text(order.itemsSummary, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
          if (order.status == OrderStatus.ready && onMarkServed != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onMarkServed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen, foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.buttonRadius)),
                ),
                child: Text('Mark Served', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
