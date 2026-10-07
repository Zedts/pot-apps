import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../screens/attendance/viewmodels/attendance_view_model.dart';
import '../common/app_toast.dart';
import '../common/confirmation_dialog.dart';

/// Action buttons for Clock-in (Absen Masuk) and Clock-out (Absen Pulang).
class AttendanceActionButtons extends StatelessWidget {
  final AttendanceViewModel viewModel;

  const AttendanceActionButtons({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final isClockedIn = viewModel.isClockedInToday;
    final isClockedOut = viewModel.isClockedOutToday;
    final isSubmitting = viewModel.isSubmitting;

    final hasStallLocation = viewModel.hasStallLocation;

    return Column(
      children: [
        // Notice if lapak coordinates are not set by Admin
        if (!isClockedIn && !hasStallLocation) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: PotColors.statusWarningBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PotColors.statusWarningBorder),
            ),
            child: const Row(
              children: [
                Icon(Iconsax.info_circle, size: 18, color: PotColors.statusWarningText),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lokasi lapak belum ditentukan oleh Admin. Presensi dinonaktifkan.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: PotColors.statusWarningText,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // 1. Absen Masuk Button
        if (!isClockedIn)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (!hasStallLocation || isSubmitting)
                  ? null
                  : () async {
                      final success = await viewModel.clockIn();
                      if (context.mounted) {
                        if (success) {
                          AppToast.show(
                            context,
                            message: 'Presensi masuk berhasil dicatat.',
                            isSuccess: true,
                          );
                        } else if (viewModel.errorMessage != null) {
                          AppToast.show(
                            context,
                            message: viewModel.errorMessage!,
                            isSuccess: false,
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: PotColors.primaryRed,
                disabledBackgroundColor: PotColors.primaryRed.withValues(alpha: 0.35),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: hasStallLocation ? 2 : 0,
                shadowColor: PotColors.primaryRed.withValues(alpha: 0.3),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.login, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Absen Masuk',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
            ),
          )
        else
          // Clock-in Completed Pill
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: PotColors.statusSuccessBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PotColors.statusSuccessBorder),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, size: 16, color: PotColors.statusSuccessText),
                const SizedBox(width: 6),
                Text(
                  'Absen Masuk Selesai (${viewModel.todayRecord?.formattedJamMasuk ?? ''})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: PotColors.statusSuccessText,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 10),

        // 2. Absen Pulang Button
        if (isClockedIn && !isClockedOut)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: isSubmitting
                  ? null
                  : () => _confirmClockOut(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: PotColors.primaryRed,
                side: const BorderSide(color: PotColors.primaryRed, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: PotColors.cardCream.withValues(alpha: 0.6),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: PotColors.primaryRed,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.logout, size: 18, color: PotColors.primaryRed),
                        SizedBox(width: 8),
                        Text(
                          'Absen Pulang',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: PotColors.primaryRed,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
            ),
          )
        else if (isClockedOut)
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: PotColors.statusNeutralBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PotColors.statusNeutralBorder),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.task_alt_rounded, size: 16, color: PotColors.statusNeutralText),
                const SizedBox(width: 6),
                Text(
                  'Absen Pulang Selesai (${viewModel.todayRecord?.formattedJamPulang ?? ''})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: PotColors.statusNeutralText,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _confirmClockOut(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Konfirmasi Absen Pulang',
      content: 'Apakah Anda yakin ingin menyelesaikan shift dan melakukan presensi pulang sekarang?',
      confirmLabel: 'Ya, Absen Pulang',
      cancelLabel: 'Batal',
      confirmColor: PotColors.primaryRed,
    );

    if (confirmed == true && context.mounted) {
      final success = await viewModel.clockOut();
      if (context.mounted) {
        if (success) {
          AppToast.show(
            context,
            message: 'Presensi pulang berhasil dicatat.',
            isSuccess: true,
          );
        } else if (viewModel.errorMessage != null) {
          AppToast.show(
            context,
            message: viewModel.errorMessage!,
            isSuccess: false,
          );
        }
      }
    }
  }
}
