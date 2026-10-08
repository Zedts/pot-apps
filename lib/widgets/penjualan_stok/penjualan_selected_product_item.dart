import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/stok_lapak_model.dart';
import '../../core/utils/currency_formatter.dart';

/// Single product item row for Phase B (Selected Products View),
/// featuring quantity stepper bounded by stock, subtotal badge, and a quick-cancel trash icon.
class PenjualanSelectedProductItem extends StatelessWidget {
  final StokLapakModel stockItem;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const PenjualanSelectedProductItem({
    super.key,
    required this.stockItem,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isMaxReached = quantity >= stockItem.stokAkhir;
    final subtotal = quantity * stockItem.productPrice;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Info & Subtotal
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
                    Text(
                      '(${CurrencyFormatter.formatRupiah(subtotal)})',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: PotColors.locationGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Maks. ${stockItem.stokAkhir} pcs tersedia',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isMaxReached ? PotColors.primaryRed : PotColors.textLight,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Stepper Box
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: PotColors.cardCream.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PotColors.warmBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minus Button
                InkWell(
                  onTap: onDecrement,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: PotColors.pureWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: PotColors.warmBorder),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '−',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: PotColors.textDark,
                        height: 1,
                      ),
                    ),
                  ),
                ),

                // Quantity Text
                SizedBox(
                  width: 30,
                  child: Text(
                    '$quantity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: PotColors.primaryRed,
                    ),
                  ),
                ),

                // Plus Button (Disabled when max stock reached)
                InkWell(
                  onTap: isMaxReached ? null : onIncrement,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isMaxReached
                          ? PotColors.cardCream
                          : PotColors.pureWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isMaxReached
                            ? PotColors.warmBorder.withValues(alpha: 0.5)
                            : PotColors.warmBorder,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isMaxReached ? PotColors.textLight : PotColors.textDark,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Trash / Cancel Button for quick removal
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: PotColors.menuPink,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PotColors.primaryRed.withValues(alpha: 0.2)),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Iconsax.trash,
                size: 15,
                color: PotColors.primaryRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
