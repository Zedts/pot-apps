import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../screens/attendance/viewmodels/attendance_view_model.dart';

/// Photo preview widget displaying Cloudinary photo from server, local captured selfie,
/// or an interactive camera capture prompt.
class AttendancePhotoPreview extends StatelessWidget {
  final AttendanceViewModel viewModel;

  const AttendancePhotoPreview({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final serverUrl = viewModel.serverPhotoUrl;
    final localPhoto = viewModel.capturedPhoto;
    final isDone = viewModel.isClockedInToday;

    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: PotColors.cardCream.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PotColors.warmBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Existing Server Photo (Cloudinary Image.network)
          if (serverUrl != null && serverUrl.isNotEmpty)
            Image.network(
              serverUrl,
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
                return _buildPlaceholder(context, isDone: true);
              },
            )
          // 2. Newly Captured Local Photo (Image.file)
          else if (localPhoto != null)
            Image.file(
              localPhoto,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            )
          // 3. Camera Prompt Placeholder
          else
            _buildPlaceholder(context, isDone: isDone),

          // Delete & Retake button overlays if local photo is staged before submission
          if (localPhoto != null && !isDone) ...[
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: viewModel.clearCapturedPhoto,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: PotColors.primaryRed.withValues(alpha: 0.85),
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
            Positioned(
              bottom: 10,
              right: 10,
              child: GestureDetector(
                onTap: viewModel.capturePhoto,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.camera, size: 14, color: Colors.white),
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

          // Completed badge overlay if clocked in (strictly read-only)
          if (isDone && serverUrl != null && serverUrl.isNotEmpty)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: PotColors.statusSuccessText.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Foto Tersimpan',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, {required bool isDone}) {
    return InkWell(
      onTap: isDone ? null : viewModel.capturePhoto,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDone ? Colors.grey.shade200 : PotColors.primaryRed.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Iconsax.camera,
                size: 22,
                color: isDone ? PotColors.textMuted : PotColors.primaryRed,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isDone ? 'Foto Presensi' : 'Ambil Foto Masuk (Selfie)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDone ? PotColors.textMuted : PotColors.primaryRed,
              ),
            ),
            if (!isDone) ...[
              const SizedBox(height: 2),
              const Text(
                'Wajib swafoto di lokasi lapak bertugas',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: PotColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
