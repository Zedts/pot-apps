import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../screens/attendance/viewmodels/attendance_view_model.dart';
import 'attendance_detail_modal.dart';
import 'attendance_status_badge.dart';

/// 5-Row Bordered History Table displaying recent attendance with "Lihat Semua" full view trigger.
class AttendanceHistoryTable extends StatelessWidget {
  final AttendanceViewModel viewModel;
  final VoidCallback onSeeAllTap;

  const AttendanceHistoryTable({
    super.key,
    required this.viewModel,
    required this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final recentList = viewModel.recentHistory;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & "Lihat Semua" Link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat Presensi Terakhir',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: PotColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              InkWell(
                onTap: onSeeAllTap,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: PotColors.primaryRed,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 16, color: PotColors.primaryRed),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (recentList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Belum ada riwayat presensi.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: PotColors.textMuted,
                  ),
                ),
              ),
            )
          else
            // Bordered Table Container
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PotColors.warmBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // Table Header Row
                  Container(
                    color: PotColors.cardCream,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            'TANGGAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: PotColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'MASUK',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: PotColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            'STATUS',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: PotColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Table Body Rows (up to 5)
                  ...recentList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isLast = index == recentList.length - 1;

                    return InkWell(
                      onTap: () {
                        AttendanceDetailModal.show(
                          context,
                          absensiId: item.id,
                          initialRecord: item,
                          viewModel: viewModel,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: isLast
                              ? null
                              : const Border(bottom: BorderSide(color: PotColors.warmBorder)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            // Tanggal + Hari subtitle
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.formattedTanggal,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: PotColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    item.dayNameIndo,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: PotColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Jam Masuk
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.formattedJamMasuk,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: PotColors.textDark,
                                ),
                              ),
                            ),

                            // Status Pill
                            Expanded(
                              flex: 4,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: AttendanceStatusBadge(status: item.status),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
