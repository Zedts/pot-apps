import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Reusable status badge / pill widget displaying standardized semantic colors
/// and localized Indonesian status labels across tables, lists, and inspection modals.
class AttendanceStatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const AttendanceStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  });

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase().trim();

    Color bg;
    Color fg;
    String label;

    if (s == AppConstants.absenTerlambat) {
      bg = PotColors.statusWarningBg;
      fg = PotColors.statusWarningText;
      label = 'Terlambat';
    } else if (s == AppConstants.absenIzin) {
      bg = PotColors.statusInfoBg;
      fg = PotColors.statusInfoText;
      label = 'Izin';
    } else if (s == AppConstants.absenHadir) {
      bg = PotColors.statusSuccessBg;
      fg = PotColors.statusSuccessText;
      label = 'Tepat Waktu';
    } else {
      bg = PotColors.statusNeutralBg;
      fg = PotColors.statusNeutralText;
      label = status;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
