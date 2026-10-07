import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/pengiriman_model.dart';
import '../attendance/attendance_status_badge.dart';

/// Card showing limited (top 5) available shipments for the stall matching ref/penerimaan.html
class PenerimaanShipmentPickerCard extends StatelessWidget {
  final List<PengirimanModel> shipments;
  final ValueChanged<PengirimanModel> onShipmentTap;
  final VoidCallback onSeeAllTap;

  const PenerimaanShipmentPickerCard({
    super.key,
    required this.shipments,
    required this.onShipmentTap,
    required this.onSeeAllTap,
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
          // Section Header matching ref/penerimaan.html
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: PotColors.primaryRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Iconsax.box_tick,
                      color: PotColors.primaryRed,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pilih Barang Pengiriman',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: PotColors.textDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onSeeAllTap,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: PotColors.primaryRed,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: PotColors.warmBorder, height: 1),

          // Items List
          if (shipments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              alignment: Alignment.center,
              child: const Text(
                'Tidak ada pengiriman aktif untuk lapak ini.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: PotColors.textMuted,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: shipments.length,
              separatorBuilder: (ctx, index) => const Divider(
                color: PotColors.warmBorder,
                height: 1,
              ),
              itemBuilder: (ctx, index) {
                final item = shipments[index];
                final creatorName = item.creator?['nama'] ?? 'Ekspedisi Pusat';

                return InkWell(
                  onTap: () => onShipmentTap(item),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: PotColors.cardCream,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: PotColors.warmBorder),
                          ),
                          child: const Icon(
                            Iconsax.truck,
                            size: 18,
                            color: PotColors.primaryRed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item.uniqueId,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: PotColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  AttendanceStatusBadge(status: item.status),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pusat • $creatorName (${item.formattedJam})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: PotColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '📦 ${item.totalItems} Jenis Produk (${item.qtyKirim} pcs)',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: PotColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Iconsax.arrow_right_3,
                          size: 16,
                          color: PotColors.textLight,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
