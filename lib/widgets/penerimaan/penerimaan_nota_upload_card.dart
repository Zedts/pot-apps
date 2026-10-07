import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';

/// Card allowing users to capture or select a photo proof for Nota Penerimaan.
/// Matches the design language and flow of Absensi Photo Preview.
class PenerimaanNotaUploadCard extends StatelessWidget {
  final File? photoFile;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onRemoveTap;

  const PenerimaanNotaUploadCard({
    super.key,
    required this.photoFile,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onRemoveTap,
  });

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
            const Text(
              'Unggah Foto Nota',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: PotColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pilih sumber pengambilan foto nota fisik pengiriman',
              style: TextStyle(
                fontSize: 12,
                color: PotColors.textMuted,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      onCameraTap();
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
                const SizedBox(width: 14),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      onGalleryTap();
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
    if (photoFile != null) {
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
            Image.file(
              photoFile!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.tick_circle, size: 14, color: PotColors.statusSuccessText),
                    SizedBox(width: 4),
                    Text(
                      'Foto Nota Terlampir',
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
            // Delete button (Top-Right)
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
            // Retake button (Bottom-Right)
            Positioned(
              bottom: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => _showSourceSelectionSheet(context),
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

    // Unpicked state: Camera upload prompt card matching ref & absensi aesthetics
    return InkWell(
      onTap: () => _showSourceSelectionSheet(context),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: PotColors.menuPink,
                shape: BoxShape.circle,
                border: Border.all(
                  color: PotColors.primaryRed.withValues(alpha: 0.15),
                ),
              ),
              child: const Icon(
                Iconsax.camera,
                color: PotColors.primaryRed,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Unggah Foto Nota',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: PotColors.primaryRed,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ambil foto nota fisik pengiriman barang',
              style: TextStyle(
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
