import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

/// Card presenting the shift's sales and revenue summary matching ref/closingan.html:
/// Tunai, QRIS, Transfer, and Total Omzet.
class ClosingSalesSummaryCard extends StatelessWidget {
  final int tunai;
  final int qris;
  final int transfer;
  final int totalOmset;

  const ClosingSalesSummaryCard({
    super.key,
    required this.tunai,
    required this.qris,
    required this.transfer,
    required this.totalOmset,
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
          // Header: Title with Emerald Dot & Omzet Shift Pill Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: PotColors.locationGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Penjualan',
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
                  color: PotColors.statusSuccessBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PotColors.statusSuccessBorder),
                ),
                child: const Text(
                  'Omzet Shift',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PotColors.statusSuccessText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: PotColors.warmBorder),
          const SizedBox(height: 12),

          // Payment Methods Breakdown Rows
          _buildRow('Tunai', CurrencyFormatter.formatRupiah(tunai)),
          const SizedBox(height: 8),
          _buildRow('QRIS', CurrencyFormatter.formatRupiah(qris)),
          const SizedBox(height: 8),
          _buildRow('Transfer', CurrencyFormatter.formatRupiah(transfer)),

          const SizedBox(height: 10),
          Divider(height: 1, color: PotColors.warmBorder.withValues(alpha: 0.7)),
          const SizedBox(height: 10),

          // Total Omzet Row - Highlighted Emerald
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: PotColors.textDark,
                ),
              ),
              Text(
                CurrencyFormatter.formatRupiah(totalOmset),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: PotColors.locationGreen,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: PotColors.textDark,
          ),
        ),
      ],
    );
  }
}
