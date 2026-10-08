import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';

/// Reusable card allowing users to capture or select a photo proof.
/// Used for Payment Proofs (QRIS/Transfer), Physical Delivery Receipt Notes (Nota),
/// and Employee Attendance Selfies across the application.
class ProofPhotoUploadCard extends StatelessWidget {
  final File? photoFile;
  final String? networkImageUrl;
  final bool isReadOnly;
  final String title;
  final String subtitle;
  final String sheetTitle;
  final String sheetSubtitle;
  final String statusText;
  final VoidCallback? onCameraTap;
  final VoidCallback? onGalleryTap;
  final VoidCallback? onRemoveTap;
  final VoidCallback? onDirectTap;

  const ProofPhotoUploadCard({
    super.key,
    this.photoFile,
    this.networkImageUrl,
    this.isReadOnly = false,
    required this.title,
    required this.subtitle,
    required this.sheetTitle,
    required this.sheetSubtitle,
    required this.statusText,
    this.onCameraTap,
    this.onGalleryTap,
    this.onRemoveTap,
    this.onDirectTap,
  });

  void _handleTap(BuildContext context) {
    if (isReadOnly) return;
    if (onDirectTap != null) {
      onDirectTap!();
      return;
    }
    if (onGalleryTap == null) {
      if (onCameraTap != null) onCameraTap!();
      return;
    }
    _showSourceSelectionSheet(context);
  }

  void _showSourceSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              sheetTitle,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: PotColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sheetSubtitle,
              style: const TextStyle(
                fontSize: 12,
                color: PotColors.textMuted,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                if (onCameraTap != null)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        onCameraTap!();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: PotColors.menuPink,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: PotColors.primaryRed.withValues(alpha: 0.2)),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.camera, color: PotColors.primaryRed, size: 26),
                            SizedBox(height: 8),
                            Text(
                              'Kamera',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: PotColors.primaryRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (onCameraTap != null && onGalleryTap != null)
                  const SizedBox(width: 14),
                if (onGalleryTap != null)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        onGalleryTap!();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: PotColors.cardCream,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: PotColors.warmBorder),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.gallery, color: PotColors.textDark, size: 26),
                            SizedBox(height: 8),
                            Text(
                              'Galeri',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: PotColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage = networkImageUrl != null && networkImageUrl!.trim().isNotEmpty;
    final hasLocalFile = photoFile != null;

    if (hasNetworkImage || hasLocalFile) {
      return Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: PotColors.cardCream.withValues(alpha: 0.6),
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
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (hasLocalFile)
              Image.file(
                photoFile!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Image.network(
                networkImageUrl!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: PotColors.primaryRed,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.broken_image, size: 32, color: PotColors.textLight),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: const TextStyle(fontSize: 11, color: PotColors.textMuted),
                        ),
                      ],
                    ),
                  );
                },
              ),

            // Status Chip (Bottom-Left)
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.tick_circle, size: 14, color: PotColors.statusSuccessText),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Delete button (Top-Right) - only visible if not read-only and local photo attached
            if (!isReadOnly && hasLocalFile && onRemoveTap != null)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onRemoveTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: PotColors.primaryRed.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.trash, size: 13, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Hapus',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Retake button (Bottom-Right) - only visible if not read-only
            if (!isReadOnly)
              Positioned(
                bottom: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => _handleTap(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.camera, size: 13, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Foto Ulang',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Unpicked state: Camera upload prompt card
    return InkWell(
      onTap: isReadOnly ? null : () => _handleTap(context),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isReadOnly ? PotColors.cardCream.withValues(alpha: 0.5) : PotColors.pureWhite,
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
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isReadOnly ? Colors.grey.shade200 : PotColors.menuPink,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isReadOnly
                      ? Colors.grey.shade300
                      : PotColors.primaryRed.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(
                Iconsax.camera,
                color: isReadOnly ? PotColors.textMuted : PotColors.primaryRed,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isReadOnly ? PotColors.textMuted : PotColors.primaryRed,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: PotColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
