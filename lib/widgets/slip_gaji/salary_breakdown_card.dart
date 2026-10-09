import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../common/custom_button.dart';

/// Summary card presenting the monthly salary breakdown as specified by the
/// slipGaji.html reference design.
///
/// Visual structure:
/// 1. Emerald "Total Gaji" banner with the final salary total
/// 2. Five labeled rows: Gaji Pokok, Bonus Penjualan, Lembur, Potongan, Kasbon
///    - Potongan is rendered in primary red to emphasize a deduction
/// 3. Primary "Lihat Detail" gradient button
class SalaryBreakdownCard extends StatelessWidget {
  final int gajiPokok;
  final int bonusPenjualan;
  final int lembur;
  final int potongan;
  final int kasbon;
  final int totalGaji;
  final bool isOpening;
  final VoidCallback onLihatDetail;

  const SalaryBreakdownCard({
    super.key,
    required this.gajiPokok,
    required this.bonusPenjualan,
    required this.lembur,
    required this.potongan,
    required this.kasbon,
    required this.totalGaji,
    required this.isOpening,
    required this.onLihatDetail,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: PotColors.statusSuccessBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PotColors.statusSuccessBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Gaji',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: PotColors.statusSuccessText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.formatRupiah(totalGaji),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: PotColors.statusSuccessText,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildRow('Gaji Pokok', CurrencyFormatter.formatRupiah(gajiPokok), false),
          const SizedBox(height: 8),
          _buildRow('Bonus Penjualan', CurrencyFormatter.formatRupiah(bonusPenjualan), false),
          const SizedBox(height: 8),
          _buildRow('Lembur', CurrencyFormatter.formatRupiah(lembur), false),
          const SizedBox(height: 8),
          _buildRow('Potongan', CurrencyFormatter.formatRupiah(potongan), true),
          const SizedBox(height: 8),
          _buildRow('Kasbon', CurrencyFormatter.formatRupiah(kasbon), false),
          const SizedBox(height: 18),
          CustomButton(
            label: 'Lihat Detail',
            onPressed: onLihatDetail,
            isLoading: isOpening,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, bool isPotongan) {
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
            fontWeight: FontWeight.w700,
            color: isPotongan ? PotColors.primaryRed : PotColors.textDark,
          ),
        ),
      ],
    );
  }
}
