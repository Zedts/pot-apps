import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/penerimaan_model.dart';
import '../attendance/attendance_status_badge.dart';
import '../common/custom_button.dart';

/// Modal bottom sheet displaying complete details of a Goods Receipt (Penerimaan) record
class PenerimaanDetailSheet extends StatelessWidget {
  final PenerimaanModel receipt;

  const PenerimaanDetailSheet({
    super.key,
    required this.receipt,
  });

  static Future<void> show(
    BuildContext context, {
    required PenerimaanModel receipt,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PenerimaanDetailSheet(receipt: receipt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = receipt.uniqueId?.isNotEmpty == true
        ? receipt.uniqueId!
        : (receipt.id.length > 14 ? '#${receipt.id.substring(0, 14)}...' : '#${receipt.id}');

    final shipmentId = receipt.pengiriman?.uniqueId.isNotEmpty == true
        ? receipt.pengiriman!.uniqueId
        : (receipt.pengirimanId.isNotEmpty ? receipt.pengirimanId : '-');

    final stallName = receipt.lapak?.nama ?? 'Lapak SPG';
    final spgName = receipt.spg?.nama ?? 'Petugas SPG';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: PotColors.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PotColors.warmBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: PotColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${receipt.dayNameIndo.isNotEmpty ? "${receipt.dayNameIndo}, " : ""}${receipt.formattedTanggal}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: PotColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                AttendanceStatusBadge(status: receipt.status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: PotColors.warmBorder, height: 1),
            const SizedBox(height: 14),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 1: Pengiriman & Petugas Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: PotColors.warmBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            icon: Iconsax.truck_fast,
                            label: 'ID Pengiriman',
                            value: shipmentId,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: PotColors.warmBorder, height: 1),
                          ),
                          _buildInfoRow(
                            icon: Iconsax.shop,
                            label: 'Lokasi Lapak',
                            value: stallName,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: PotColors.warmBorder, height: 1),
                          ),
                          _buildInfoRow(
                            icon: Iconsax.user,
                            label: 'Penerima / SPG',
                            value: spgName,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Card 2: Quantities Breakdown
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: PotColors.warmBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Jumlah Diterima',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: PotColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${receipt.qtyTerima} pcs',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: PotColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: PotColors.warmBorder,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status Verifikasi',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: PotColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      receipt.isSesuai
                                          ? Iconsax.tick_circle
                                          : Iconsax.warning_2,
                                      size: 16,
                                      color: receipt.isSesuai
                                          ? PotColors.statusSuccessText
                                          : PotColors.statusErrorText,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      receipt.isSesuai ? 'Sesuai' : 'Ada Selisih',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: receipt.isSesuai
                                          ? PotColors.statusSuccessText
                                          : PotColors.statusErrorText,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Card 3: Catatan (if any)
                    if (receipt.catatan.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: PotColors.cardCream,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: PotColors.warmBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Iconsax.note_text,
                                  size: 16,
                                  color: PotColors.primaryRed,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Catatan Petugas',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: PotColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              receipt.catatan,
                              style: const TextStyle(
                                fontSize: 13,
                                color: PotColors.textDark,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Card 4: Foto Nota (if uploaded)
                    if (receipt.notaUrl != null && receipt.notaUrl!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: PotColors.pureWhite,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: PotColors.warmBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Iconsax.image,
                                  size: 18,
                                  color: PotColors.primaryRed,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Foto Nota Terlampir',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: PotColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                receipt.notaUrl!,
                                width: double.infinity,
                                height: 160,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    height: 160,
                                    color: PotColors.cardCream,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: PotColors.primaryRed,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 80,
                                    color: PotColors.cardCream,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Gagal memuat foto nota',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: PotColors.textMuted,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Action: Close Button
            CustomButton(
              label: 'Tutup',
              isOutlined: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
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
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: PotColors.cardCream,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: PotColors.warmBorder),
          ),
          child: Icon(icon, size: 16, color: PotColors.primaryRed),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: PotColors.textMuted,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: PotColors.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
