import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../screens/attendance/viewmodels/attendance_view_model.dart';

/// Digital clock display with dynamic attendance status label.
class AttendanceClockCard extends StatelessWidget {
  final AttendanceViewModel viewModel;

  const AttendanceClockCard({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = _resolveStatusText();
    final isDone = viewModel.isClockedOutToday;
    final isIzin = viewModel.isIzinToday;
    final isClockedIn = viewModel.isClockedInToday;

    Color badgeColor = PotColors.textMuted;
    Color badgeBg = PotColors.cardCream;

    if (isIzin) {
      badgeColor = PotColors.statusWarningText;
      badgeBg = PotColors.statusWarningBg;
    } else if (isDone) {
      badgeColor = PotColors.statusSuccessText;
      badgeBg = PotColors.statusSuccessBg;
    } else if (isClockedIn) {
      badgeColor = PotColors.statusInfoText;
      badgeBg = PotColors.statusInfoBg;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Big Digital Clock
        Text(
          viewModel.formattedCurrentTime,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: PotColors.textDark,
            letterSpacing: -1.0,
            fontFeatures: [],
          ),
        ),
        const SizedBox(height: 2),

        // Shift Schedule Badge
        Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: PotColors.brandGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Shift ${viewModel.userShiftLabel} • ${viewModel.shiftScheduleDisplay}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: PotColors.brandGreen,
              letterSpacing: -0.1,
            ),
          ),
        ),

        // Status Badge Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: badgeColor.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: badgeColor,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ],
    );
  }

  String _resolveStatusText() {
    if (viewModel.isIzinToday) {
      final ket = viewModel.todayRecord?.keterangan.trim() ?? '';
      return ket.isNotEmpty ? 'Izin Tercatat ($ket)' : 'Izin Tercatat';
    }
    if (viewModel.isClockedOutToday) {
      return 'Presensi Selesai (${viewModel.todayRecord?.formattedJamPulang ?? ''})';
    }
    if (viewModel.isClockedInToday) {
      return 'Sudah Absen Masuk (${viewModel.todayRecord?.formattedJamMasuk ?? ''})';
    }
    return 'Belum Absen Masuk';
  }
}
