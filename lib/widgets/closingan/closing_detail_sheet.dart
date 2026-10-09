import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/closing_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../attendance/attendance_status_badge.dart';

/// Modal bottom sheet displaying detailed closing audit information
class ClosingDetailSheet extends StatelessWidget {
  final ClosingModel item;

  const ClosingDetailSheet({
    super.key,
    required this.item,
  });

  static Future<void> show(BuildContext context, ClosingModel item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClosingDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: PotColors.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: PotColors.warmBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Laporan Closing',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: PotColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.formattedTanggalFullWithTime,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: PotColors.textMuted,
                      ),
                    ),
                  ],
                ),
                AttendanceStatusBadge(status: item.status),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: PotColors.warmBorder),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Stall & SPG Info Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: PotColors.pureWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: PotColors.warmBorder),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Iconsax.shop,
                          label: 'Lapak',
                          value: item.lapak?.nama ?? 'Lapak #${item.lapakId}',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          icon: Iconsax.user,
                          label: 'SPG Bertugas',
                          value: item.spg?.nama ?? 'SPG',
                        ),
                        if (item.validator != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Iconsax.shield_tick,
                            label: 'Divalidasi Oleh',
                            value: item.validator?.nama ?? 'Admin',
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Inventory Reconciliation Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: PotColors.pureWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: PotColors.warmBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rekonsiliasi Stok',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: PotColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildDataRow('Stok Sistem', '${item.stokSistem} pcs'),
                        const SizedBox(height: 6),
                        _buildDataRow('Stok Fisik', '${item.stokFisik} pcs'),
                        const SizedBox(height: 8),
                        const Divider(height: 1, color: PotColors.warmBorder),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Selisih Stok',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: PotColors.textDark,
                              ),
                            ),
                            Text(
                              item.selisihStok == 0
                                  ? '0 pcs (Sesuai)'
                                  : '${item.selisihStok > 0 ? "+${item.selisihStok}" : item.selisihStok} pcs',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: item.selisihStok == 0
                                    ? PotColors.statusSuccessText
                                    : (item.selisihStok < 0 ? PotColors.statusWarningText : PotColors.statusInfoText),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Financial Reconciliation Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: PotColors.pureWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: PotColors.warmBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rekonsiliasi Keuangan & Omzet',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: PotColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildDataRow('Tunai (Sistem)', CurrencyFormatter.formatRupiah(item.tunaiSistem)),
                        const SizedBox(height: 6),
                        _buildDataRow('QRIS (Sistem)', CurrencyFormatter.formatRupiah(item.qrisSistem)),
                        const SizedBox(height: 6),
                        _buildDataRow('Transfer (Sistem)', CurrencyFormatter.formatRupiah(item.transferSistem)),
                        const SizedBox(height: 6),
                        _buildDataRow('Total Omzet Shift', CurrencyFormatter.formatRupiah(item.totalOmset), isBold: true),
                        const SizedBox(height: 8),
                        const Divider(height: 1, color: PotColors.warmBorder),
                        const SizedBox(height: 8),
                        _buildDataRow('Uang Tunai Fisik', CurrencyFormatter.formatRupiah(item.uangTunaiFisik)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Selisih Kasir',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: PotColors.textDark,
                              ),
                            ),
                            Text(
                              item.selisihUang == 0
                                  ? 'Rp 0 (Sesuai)'
                                  : '${item.selisihUang > 0 ? "+" : ""}${CurrencyFormatter.formatRupiah(item.selisihUang)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: item.selisihUang == 0
                                    ? PotColors.statusSuccessText
                                    : (item.selisihUang < 0 ? PotColors.statusWarningText : PotColors.statusInfoText),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Catatan Section
                  if (item.catatan.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: PotColors.pureWhite,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: PotColors.warmBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Catatan SPG',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: PotColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.catatan,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: PotColors.textDark,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: PotColors.primaryRed),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: PotColors.textMuted,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: PotColors.textDark,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? PotColors.textDark : PotColors.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? PotColors.locationGreen : PotColors.textDark,
          ),
        ),
      ],
    );
  }
}
