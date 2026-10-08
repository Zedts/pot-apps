import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/stok_lapak_model.dart';
import '../../core/utils/currency_formatter.dart';

/// Card presenting the 4 core inventory metrics for a product or overall summary:
/// Stok Awal, Stok Masuk, Stok Terjual, and Stok Akhir
class StokBalanceCard extends StatelessWidget {
  final StokLapakModel? stockItem;
  final bool isSummary;
  final int? totalAwal;
  final int? totalMasuk;
  final int? totalTerjual;
  final int? totalAkhir;

  const StokBalanceCard({
    super.key,
    required this.stockItem,
    this.isSummary = false,
    this.totalAwal,
    this.totalMasuk,
    this.totalTerjual,
    this.totalAkhir,
  });

  @override
  Widget build(BuildContext context) {
    final awal = isSummary ? (totalAwal ?? 0) : (stockItem?.stokAwal ?? 0);
    final masuk = isSummary ? (totalMasuk ?? 0) : (stockItem?.stokMasuk ?? 0);
    final terjual = isSummary ? (totalTerjual ?? 0) : (stockItem?.stokTerjual ?? 0);
    final akhir = isSummary ? (totalAkhir ?? 0) : (stockItem?.stokAkhir ?? 0);

    final title = isSummary ? 'Total Keseimbangan Stok' : (stockItem?.productName ?? 'Produk');
    final subtitle = isSummary
        ? 'Ringkasan seluruh produk di lapak ini'
        : (stockItem?.produk?.harga != null
            ? CurrencyFormatter.formatRupiah(stockItem!.produk!.harga)
            : 'Katalog Produk');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSummary ? PotColors.cardCream : PotColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSummary ? PotColors.primaryRed.withValues(alpha: 0.2) : PotColors.warmBorder,
          width: isSummary ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Product / Summary title & Price/Subtitle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isSummary ? 14 : 13,
                        fontWeight: FontWeight.w800,
                        color: isSummary ? PotColors.primaryRed : PotColors.textDark,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: PotColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSummary)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: PotColors.menuPink,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PotColors.primaryRed.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    'Sisa: $akhir',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: PotColors.primaryRed,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // 4-Metric Grid
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: isSummary ? PotColors.pureWhite : PotColors.cardCream.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PotColors.warmBorder),
            ),
            child: Row(
              children: [
                _buildMetricColumn('Awal', '$awal', PotColors.textDark),
                _buildDivider(),
                _buildMetricColumn('Masuk', '+$masuk', PotColors.locationGreen),
                _buildDivider(),
                _buildMetricColumn('Terjual', '-$terjual', PotColors.primaryRed),
                _buildDivider(),
                _buildMetricColumn('Akhir', '$akhir', isSummary ? PotColors.primaryRed : PotColors.textDark, isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, Color valueColor, {bool isBold = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: PotColors.textMuted,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w800,
              color: valueColor,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: PotColors.warmBorder,
    );
  }
}
