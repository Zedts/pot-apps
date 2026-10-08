import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/penjualan_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../screens/penjualan_stok/viewmodels/penjualan_stok_view_model.dart';

/// Modal bottom sheet presenting past sales transaction history
class RiwayatPenjualanSheet extends StatelessWidget {
  final PenjualanStokViewModel viewModel;

  const RiwayatPenjualanSheet({
    super.key,
    required this.viewModel,
  });

  static Future<void> show(BuildContext context, PenjualanStokViewModel viewModel) {
    viewModel.loadSalesHistory();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RiwayatPenjualanSheet(viewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final history = viewModel.salesHistory;
        final isLoading = viewModel.isLoadingHistory;

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
              // Top Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Sheet Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Riwayat Penjualan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: PotColors.textDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          viewModel.stall?.nama ?? 'Lapak SPG',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: PotColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: PotColors.cardCream,
                          shape: BoxShape.circle,
                          border: Border.all(color: PotColors.warmBorder),
                        ),
                        child: const Icon(Icons.close, size: 16, color: PotColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: PotColors.warmBorder),

              // Content Area
              Flexible(
                child: isLoading && history.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(color: PotColors.primaryRed),
                        ),
                      )
                    : history.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: PotColors.menuPink,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: PotColors.primaryRed.withValues(alpha: 0.15),
                                      ),
                                    ),
                                    child: const Icon(
                                      Iconsax.document_text,
                                      color: PotColors.primaryRed,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Belum Ada Penjualan',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: PotColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Transaksi penjualan yang berhasil dicatat akan muncul di riwayat ini.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: PotColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                            itemCount: history.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = history[index];
                              return _buildHistoryCard(context, item);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryCard(BuildContext context, PenjualanModel item) {
    final isTunai = item.isTunai;
    final proofUrl = item.resolvedBuktiUrl;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PotColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PotColors.warmBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Date & Payment Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.formattedDateTime,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: PotColors.textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isTunai ? PotColors.cardCream : PotColors.menuPink,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isTunai
                        ? PotColors.warmBorder
                        : PotColors.primaryRed.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  item.metodePembayaran.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isTunai ? PotColors.textDark : PotColors.primaryRed,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Total & Item count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.formatRupiah(item.totalHarga),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: PotColors.locationGreen,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                '${item.totalQty} pcs',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: PotColors.textDark,
                ),
              ),
            ],
          ),

          // Items Details
          if (item.items.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PotColors.cardCream.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: item.items.map((sub) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${sub.qty}x ${sub.namaProduk}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: PotColors.textDark,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatRupiah(sub.subtotal),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: PotColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          // Payment Proof Thumbnail if available
          if (proofUrl != null && proofUrl.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Iconsax.image, size: 14, color: PotColors.primaryRed),
                const SizedBox(width: 4),
                const Text(
                  'Bukti Pembayaran Terlampir',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PotColors.primaryRed,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showFullImageModal(context, proofUrl),
                  child: const Text(
                    'Lihat Foto',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: PotColors.primaryRed,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showFullImageModal(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    padding: const EdgeInsets.all(48),
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        color: PotColors.primaryRed,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    color: PotColors.pureWhite,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.warning_2, size: 40, color: PotColors.primaryRed),
                        SizedBox(height: 8),
                        Text(
                          'Gagal memuat gambar bukti pembayaran.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: PotColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
