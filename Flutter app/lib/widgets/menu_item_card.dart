import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../models/menu_item.dart';

/// Menu item card with quantity controls and sold-out badge
class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  const MenuItemCard({super.key, required this.item, required this.quantity, required this.onQuantityChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(item.description, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary), maxLines: 2),
                ],
                if (item.isSoldOut) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.errorRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text('Sold Out', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.errorRed)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('€${item.price.toStringAsFixed(2)}', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryTeal)),
              const SizedBox(height: 8),
              if (item.isSoldOut)
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: AppColors.border, shape: BoxShape.circle),
                  child: const Center(child: FaIcon(FontAwesomeIcons.plus, color: AppColors.textSecondary, size: 14)),
                )
              else if (quantity == 0)
                GestureDetector(
                  onTap: () => onQuantityChanged(1),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: AppColors.primaryTeal, shape: BoxShape.circle),
                    child: const Center(child: FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 14)),
                  ),
                )
              else
                Row(mainAxisSize: MainAxisSize.min, children: [
                  GestureDetector(
                    onTap: () => onQuantityChanged(quantity - 1),
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: AppColors.border, shape: BoxShape.circle),
                      child: const Center(child: FaIcon(FontAwesomeIcons.minus, size: 12, color: AppColors.textSecondary)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('$quantity', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  GestureDetector(
                    onTap: () => onQuantityChanged(quantity + 1),
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: AppColors.primaryTeal, shape: BoxShape.circle),
                      child: const Center(child: FaIcon(FontAwesomeIcons.plus, size: 12, color: Colors.white)),
                    ),
                  ),
                ]),
            ],
          ),
        ],
      ),
    );
  }
}
