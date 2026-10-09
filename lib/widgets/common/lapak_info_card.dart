import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/lapak_model.dart';

/// Reusable stall metadata card displaying stall name and live verified status.
/// Shared across Closingan, Penerimaan, and Absensi screens.
class LapakInfoCard extends StatelessWidget {
  final LapakModel? stall;
  final String? customTitle;
  final String? statusText;
  final bool isVerified;

  const LapakInfoCard({
    super.key,
    required this.stall,
    this.customTitle,
    this.statusText,
    this.isVerified = true,
  });

  @override
  Widget build(BuildContext context) {
    final stallName = stall?.nama.isNotEmpty == true ? stall!.nama : 'Lapak Belum Ditugaskan';
    final resolvedStatus = statusText ?? (isVerified ? 'Lokasi Terverifikasi (Lapak Aktif)' : 'Lapak Belum Terverifikasi');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: PotColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PotColors.warmBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Icon Box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PotColors.cardCream,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PotColors.warmBorder),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Iconsax.location,
              size: 20,
              color: PotColors.primaryRed,
            ),
          ),
          const SizedBox(width: 12),

          // Stall Name and Verification Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      customTitle ?? 'Lapak: ',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: PotColors.textMuted,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        stallName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: PotColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isVerified ? PotColors.locationGreen : PotColors.textLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        resolvedStatus,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isVerified ? PotColors.statusSuccessText : PotColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
