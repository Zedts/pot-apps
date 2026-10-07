import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/pengiriman_model.dart';

/// Card showing the received items checklist with stepper controls & soft orange selisih styling
class PenerimaanReceivedItemsCard extends StatelessWidget {
  final PengirimanModel shipment;
  final List<ReceivedItemVerification> items;
  final void Function(int index, int newQty) onQtyChanged;
  final VoidCallback onBackTap;

  const PenerimaanReceivedItemsCard({
    super.key,
    required this.shipment,
    required this.items,
    required this.onQtyChanged,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: PotColors.pureWhite,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: PotColors.warmBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Back Arrow Button matching header style (adjusted compact size)
          Row(
            children: [
              InkWell(
                onTap: onBackTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: PotColors.cardCream,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: PotColors.warmBorder),
                    boxShadow: [
                      BoxShadow(
                        color: PotColors.primaryRed.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: PotColors.primaryRed,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daftar Barang Diterima',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: PotColors.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      shipment.uniqueId,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: PotColors.primaryRed,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: PotColors.cardCream,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PotColors.warmBorder),
                ),
                child: Text(
                  '${items.length} Barang',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PotColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: PotColors.warmBorder, height: 1),
          const SizedBox(height: 12),

          // Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (ctx, index) => const SizedBox(height: 10),
            itemBuilder: (ctx, index) {
              final item = items[index];
              final isSelisih = item.isSelisih;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelisih ? PotColors.menuOrange : PotColors.pureWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelisih ? PotColors.borderOrange : PotColors.warmBorder,
                    width: isSelisih ? 1.2 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item Title
                          Text(
                            item.namaProduk,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: PotColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Subtitle: kirim & terima
                          Text(
                            'Kirim: ${item.qtyKirim} ${item.jenisSatuan} • Terima: ${item.qtyTerima} ${item.jenisSatuan}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelisih ? PotColors.statusWarningText : PotColors.textMuted,
                            ),
                          ),
                          if (isSelisih) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: PotColors.statusWarningBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: PotColors.statusWarningBorder),
                              ),
                              child: Text(
                                item.selisihDiff > 0
                                    ? 'Lebih +${item.selisihDiff} ${item.jenisSatuan}'
                                    : 'Kurang ${item.selisihDiff} ${item.jenisSatuan}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: PotColors.statusWarningText,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Stepper: - and +
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelisih ? PotColors.borderOrange : PotColors.warmBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (item.qtyTerima > 0) {
                                onQtyChanged(index, item.qtyTerima - 1);
                              }
                            },
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Icon(Icons.remove, size: 16, color: PotColors.textDark),
                            ),
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 28),
                            alignment: Alignment.center,
                            child: Text(
                              '${item.qtyTerima}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: isSelisih ? PotColors.statusWarningText : PotColors.textDark,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              onQtyChanged(index, item.qtyTerima + 1);
                            },
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Icon(Icons.add, size: 16, color: PotColors.textDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
