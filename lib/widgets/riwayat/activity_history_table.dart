import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/activity_history_model.dart';
import '../../core/utils/date_formatter.dart';

class ActivityHistoryTable extends StatelessWidget {
  final List<ActivityHistoryModel> entries;
  final bool searchActive;

  const ActivityHistoryTable({
    super.key,
    required this.entries,
    this.searchActive = false,
  });

  String _activityLabel(String type) {
    switch (type) {
      case AppConstants.activityClockIn:
        return 'Masuk';
      case AppConstants.activityClockOut:
        return 'Pulang';
      case AppConstants.activityReceiveGoods:
        return 'Terima Barang';
      case AppConstants.activityProcessSale:
        return 'Penjualan';
      case AppConstants.activityDailyClosing:
        return 'Closing';
      case AppConstants.activityProfileUpdated:
        return 'Profil Diperbarui';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            searchActive
                ? 'Aktivitas tidak ditemukan.'
                : 'Belum ada riwayat aktivitas di perangkat ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: PotColors.textMuted,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PotColors.warmBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: PotColors.cardCream,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: const Row(
              children: [
                Expanded(flex: 4, child: Text('WAKTU', style: _HeaderText())),
                Expanded(
                  flex: 4,
                  child: Text('AKTIVITAS', style: _HeaderText()),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    'KETERANGAN',
                    textAlign: TextAlign.end,
                    style: _HeaderText(),
                  ),
                ),
              ],
            ),
          ),
          ...entries.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == entries.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(
                        bottom: BorderSide(color: PotColors.warmBorder),
                      ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormatter.formatShortDate(item.occurredAt),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: PotColors.textDark,
                          ),
                        ),
                        Text(
                          DateFormatter.formatTime(item.occurredAt),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: PotColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      _activityLabel(item.activityType),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: PotColors.textDark,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      item.description,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: PotColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _HeaderText extends TextStyle {
  const _HeaderText()
    : super(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: PotColors.textMuted,
        letterSpacing: 0.5,
      );
}
