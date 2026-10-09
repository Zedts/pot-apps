import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Card presenting the shift's inventory summary matching ref/closingan.html:
/// Stok Awal, Barang Masuk, Terjual, and Stok Akhir (Sistem).
class ClosingInventorySummaryCard extends StatelessWidget {
  final int stokAwal;
  final int barangMasuk;
  final int terjual;
  final int stokAkhir;

  const ClosingInventorySummaryCard({
    super.key,
    required this.stokAwal,
    required this.barangMasuk,
    required this.terjual,
    required this.stokAkhir,
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
          // Header: Title with Red Dot & Pill Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: PotColors.primaryRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ringkasan',
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
                  color: PotColors.cardCream,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PotColors.warmBorder),
                ),
                child: const Text(
                  'Inventaris',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PotColors.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: PotColors.warmBorder),
          const SizedBox(height: 12),

          // Data Rows
          _buildRow('Stok Awal', '$stokAwal pcs', isBoldValue: true),
          const SizedBox(height: 8),
          _buildRow('Barang Masuk', '$barangMasuk pcs', isBoldValue: true),
          const SizedBox(height: 8),
          _buildRow('Terjual', '$terjual pcs', isBoldValue: true),

          const SizedBox(height: 10),
          Divider(height: 1, color: PotColors.warmBorder.withValues(alpha: 0.7)),
          const SizedBox(height: 10),

          // Stok Akhir (Sistem) Row - Highlighted
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Stok Akhir (Sistem)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: PotColors.textDark,
                ),
              ),
              Text(
                '$stokAkhir pcs',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: PotColors.primaryRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBoldValue = false}) {
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
            fontWeight: isBoldValue ? FontWeight.w700 : FontWeight.w500,
            color: PotColors.textDark,
          ),
        ),
      ],
    );
  }
}
