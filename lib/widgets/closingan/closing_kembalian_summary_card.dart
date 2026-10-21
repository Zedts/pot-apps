import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

/// Card presenting the shift's change retention (Kembalian Disimpan) summary:
/// Total Kembalian Disimpan, Jumlah Transaksi, and allocation status.
class ClosingKembalianSummaryCard extends StatelessWidget {
  final int totalKembalian;
  final int jumlahTransaksi;

  const ClosingKembalianSummaryCard({
    super.key,
    required this.totalKembalian,
    required this.jumlahTransaksi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PotColors.pureWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PotColors.warmBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Title with Orange Dot & Simpan Kembalian Pill Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: PotColors.iconOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Kembalian',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: PotColors.textDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: PotColors.menuOrange,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PotColors.borderOrange),
                ),
                child: const Text(
                  'Simpan Kembalian',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PotColors.iconOrange,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: PotColors.warmBorder),
          const SizedBox(height: 12),

          // Row 1: Total Kembalian Disimpan
          _buildRow(
            'Total Kembalian Disimpan',
            CurrencyFormatter.formatRupiah(totalKembalian),
            isOrangeValue: true,
          ),
          const SizedBox(height: 8),

          // Row 2: Jumlah Transaksi
          _buildRow(
            'Jumlah Transaksi',
            '$jumlahTransaksi Transaksi',
          ),

          const SizedBox(height: 10),
          Divider(height: 1, color: PotColors.warmBorder.withValues(alpha: 0.7)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isOrangeValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: PotColors.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isOrangeValue ? PotColors.iconOrange : PotColors.textDark,
          ),
        ),
      ],
    );
  }
}
