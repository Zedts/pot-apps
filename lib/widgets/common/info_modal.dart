import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// System information modal dialog displaying app metadata and connection status.
class InfoModal extends StatelessWidget {
  const InfoModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.50),
      builder: (_) => const InfoModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: PotColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: PotColors.warmBorder),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PotColors.primaryRed.withValues(alpha: 0.10),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.info_outline,
                size: 24,
                color: PotColors.primaryRed,
              ),
            ),
            const SizedBox(height: 12),

            // Title & Subtitle
            const Text(
              'POT Mobile System',
              style: TextStyle(
                color: PotColors.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Presensi Oleh² Turki Internal Client',
              style: TextStyle(
                color: PotColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),

            // Info rows
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: PotColors.cardCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PotColors.warmBorder),
              ),
              child: const Column(
                children: [
                  _InfoRow(label: 'Versi:', value: 'v3.1.0'),
                  SizedBox(height: 8),
                  _InfoRow(
                    label: 'Koneksi:',
                    value: 'Server Aktif',
                    isStatus: true,
                  ),
                  SizedBox(height: 8),
                  _InfoRow(
                    label: 'Dukungan:',
                    value: 'hrd@olehturki.id',
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Close Button
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: PotColors.bgCream,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: PotColors.warmBorder),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Tutup',
                  style: TextStyle(
                    color: PotColors.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isStatus;
  final bool isHighlight;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isStatus = false,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: PotColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (isStatus)
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF059669),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        else
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? PotColors.primaryRed : PotColors.textDark,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
