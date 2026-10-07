import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/absensi_model.dart';
import '../../widgets/attendance/attendance_detail_modal.dart';
import '../../widgets/attendance/attendance_status_badge.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_toast.dart';
import 'viewmodels/attendance_view_model.dart';

/// Full Archive History Screen ("Lihat Semua") for viewing all past attendance records.
class AttendanceHistoryScreen extends StatefulWidget {
  final AttendanceViewModel viewModel;

  const AttendanceHistoryScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  String _selectedFilter = 'semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.viewModel.refreshAttendanceData();
      }
    });
  }

  Future<void> _handleRefresh() async {
    await widget.viewModel.refreshAttendanceData();
    if (!mounted) return;
    AppToast.show(
      context,
      message: 'Data riwayat presensi berhasil diperbarui.',
      isSuccess: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final allRecords = widget.viewModel.history;
        final filteredRecords = _filterRecords(allRecords);

        final totalHadir = allRecords.where((r) => r.status.toLowerCase() == 'hadir').length;
        final totalTerlambat = allRecords.where((r) => r.status.toLowerCase() == 'terlambat').length;
        final totalIzin = allRecords.where((r) => r.status.toLowerCase() == 'izin').length;

        return Scaffold(
          backgroundColor: PotColors.bgCream,
          appBar: const AppHeader(
            showBackButton: true,
            title: 'Riwayat Presensi',
          ),
          body: RefreshIndicator(
            color: PotColors.primaryRed,
            backgroundColor: Colors.white,
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Metric Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          label: 'Tepat Waktu',
                          count: totalHadir,
                          color: PotColors.statusSuccessText,
                          bgColor: PotColors.statusSuccessBg,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          label: 'Terlambat',
                          count: totalTerlambat,
                          color: PotColors.statusWarningText,
                          bgColor: PotColors.statusWarningBg,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          label: 'Izin / Sakit',
                          count: totalIzin,
                          color: PotColors.statusInfoText,
                          bgColor: PotColors.statusInfoBg,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 2. Filter Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterPill('semua', 'Semua (${allRecords.length})'),
                        const SizedBox(width: 8),
                        _buildFilterPill('hadir', 'Tepat Waktu ($totalHadir)'),
                        const SizedBox(width: 8),
                        _buildFilterPill('terlambat', 'Terlambat ($totalTerlambat)'),
                        const SizedBox(width: 8),
                        _buildFilterPill('izin', 'Izin ($totalIzin)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Full Records List
                  if (filteredRecords.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      alignment: Alignment.center,
                      child: const Text(
                        'Tidak ada data presensi pada kategori ini.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: PotColors.textMuted,
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredRecords.length,
                        separatorBuilder: (ctx, index) => const Divider(
                          color: PotColors.warmBorder,
                          height: 1,
                        ),
                        itemBuilder: (ctx, index) {
                          final item = filteredRecords[index];
                          return InkWell(
                            onTap: () {
                              AttendanceDetailModal.show(
                                context,
                                absensiId: item.id,
                                initialRecord: item,
                                viewModel: widget.viewModel,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.formattedTanggal,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: PotColors.textDark,
                                          ),
                                        ),
                                        Text(
                                          item.dayNameIndo,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: PotColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.formattedJamMasuk,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: PotColors.textDark,
                                          ),
                                        ),
                                        Text(
                                          'Plg: ${item.formattedJamPulang}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: PotColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<AbsensiModel> _filterRecords(List<AbsensiModel> list) {
    if (_selectedFilter == 'semua') return list;
    return list.where((r) => r.status.toLowerCase() == _selectedFilter).toList();
  }

  Widget _buildSummaryCard({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filterKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? PotColors.primaryRed : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? PotColors.primaryRed : PotColors.warmBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : PotColors.textDark,
          ),
        ),
      ),
    );
  }
}
