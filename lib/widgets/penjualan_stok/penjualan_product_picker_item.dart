import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/stok_lapak_model.dart';
import '../../core/utils/currency_formatter.dart';

/// Single product item row for Phase A (Product Selection),
/// featuring title, price, available stock badge, and a plus/check selection toggle button.
class PenjualanProductPickerItem extends StatelessWidget {
  final StokLapakModel stockItem;
  final bool isSelected;
  final VoidCallback onToggle;

  const PenjualanProductPickerItem({
    super.key,
    required this.stockItem,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Details & Stock Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stockItem.productName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: PotColors.textDark,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      CurrencyFormatter.formatRupiah(stockItem.productPrice),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: PotColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: PotColors.menuGreen,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: PotColors.borderGreen),
                      ),
                      child: Text(
                        'Stok: ${stockItem.stokAkhir}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: PotColors.statusSuccessText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Selection Plus/Check Button
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? PotColors.primaryRed : PotColors.cardCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? PotColors.primaryRed : PotColors.warmBorder,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: PotColors.primaryRed.withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Icon(
                isSelected ? Icons.check_rounded : Iconsax.add,
                size: 18,
                color: isSelected ? PotColors.pureWhite : PotColors.primaryRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
