import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/closing_model.dart';
import '../../core/models/lapak_model.dart';
import '../../core/models/user_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/attendance/attendance_status_badge.dart';
import '../../widgets/closingan/closing_detail_sheet.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_toast.dart';
import 'viewmodels/closing_history_view_model.dart';

/// Standalone History Archive Screen ("Riwayat Closing") for reviewing past closing reports
class ClosingHistoryScreen extends StatefulWidget {
  final UserModel? currentUser;
  final LapakModel? currentStall;

  const ClosingHistoryScreen({
    super.key,
    this.currentUser,
    this.currentStall,
  });

  @override
  State<ClosingHistoryScreen> createState() => _ClosingHistoryScreenState();
}

class _ClosingHistoryScreenState extends State<ClosingHistoryScreen> {
  late final ClosingHistoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ClosingHistoryViewModel(
      currentUser: widget.currentUser,
      currentStall: widget.currentStall,
    );
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final list = _viewModel.filteredHistory;

        return Scaffold(
          backgroundColor: PotColors.bgCream,
          appBar: const AppHeader(
            showBackButton: true,
            title: 'Riwayat Closing',
          ),
          body: RefreshIndicator(
            color: PotColors.primaryRed,
            backgroundColor: Colors.white,
            displacement: 40,
            onRefresh: () async {
              await _viewModel.fetchHistory();
              if (context.mounted) {
                AppToast.show(
                  context,
                  message: 'Riwayat closing diperbarui.',
                  isSuccess: true,
                );
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Metric Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          label: 'Total',
                          count: _viewModel.totalCount,
                          color: PotColors.textDark,
                          bgColor: PotColors.pureWhite,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          label: 'Sesuai',
                          count: _viewModel.balancedCount,
                          color: PotColors.statusSuccessText,
                          bgColor: PotColors.statusSuccessBg,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          label: 'Selisih',
                          count: _viewModel.discrepantCount,
                          color: PotColors.statusWarningText,
                          bgColor: PotColors.statusWarningBg,
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
                        _buildFilterPill('semua', 'Semua (${_viewModel.totalCount})'),
                        const SizedBox(width: 8),
                        _buildFilterPill('pending', 'Pending (${_viewModel.pendingCount})'),
                        const SizedBox(width: 8),
                        _buildFilterPill('terverifikasi', 'Terverifikasi (${_viewModel.terverifikasiCount})'),
                        const SizedBox(width: 8),
                        _buildFilterPill('perlu_revisi', 'Perlu Revisi (${_viewModel.perluRevisiCount})'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Content States
                  if (_viewModel.isLoading && list.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(color: PotColors.primaryRed),
                      ),
                    )
                  else if (_viewModel.errorMessage != null && list.isEmpty)
                    _buildErrorState()
                  else if (list.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      separatorBuilder: (ctx, index) => const SizedBox(height: 12),
                      itemBuilder: (ctx, index) {
                        return _buildClosingCard(list[index]);
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
        color: bgColor == PotColors.pureWhite ? PotColors.pureWhite : bgColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bgColor == PotColors.pureWhite
              ? PotColors.warmBorder
              : color.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
              color: color == PotColors.textDark ? PotColors.textMuted : color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String filterKey, String label) {
    final isSelected = _viewModel.selectedFilter == filterKey;
    return GestureDetector(
      onTap: () => _viewModel.setFilter(filterKey),
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

  Widget _buildClosingCard(ClosingModel item) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => ClosingDetailSheet.show(context, item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Date & Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Iconsax.calendar_1,
                          size: 15,
                          color: PotColors.primaryRed,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.formattedTanggalFull,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: PotColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    AttendanceStatusBadge(status: item.status),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: PotColors.warmBorder),
                const SizedBox(height: 10),

                // Middle Rows: Omzet & Discrepancies
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Omzet',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: PotColors.textMuted,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatRupiah(item.totalOmset),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: PotColors.locationGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Stock and Cash Discrepancy Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stok: ${item.stokFisik} pcs',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: PotColors.textDark,
                      ),
                    ),
                    Text(
                      item.selisihStok == 0
                          ? 'Stok Sesuai'
                          : '${item.selisihStok > 0 ? "+${item.selisihStok}" : item.selisihStok} pcs',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: item.selisihStok == 0
                            ? PotColors.statusSuccessText
                            : PotColors.statusWarningText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Uang Fisik: ${CurrencyFormatter.formatRupiah(item.uangTunaiFisik)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: PotColors.textDark,
                      ),
                    ),
                    Text(
                      item.selisihUang == 0
                          ? 'Kasir Sesuai'
                          : (item.selisihUang > 0 ? '+${CurrencyFormatter.formatRupiah(item.selisihUang)}' : CurrencyFormatter.formatRupiah(item.selisihUang)),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: item.selisihUang == 0
                            ? PotColors.statusSuccessText
                            : PotColors.statusWarningText,
                      ),
                    ),
                  ],
                ),

                // Notes Snippet (if any)
                if (item.catatan.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: PotColors.cardCream,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: PotColors.warmBorder),
                    ),
                    child: Text(
                      'Catatan: "${item.catatan}"',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: PotColors.textDark,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: PotColors.menuPink,
                shape: BoxShape.circle,
                border: Border.all(color: PotColors.primaryRed.withValues(alpha: 0.15)),
              ),
              child: const Icon(
                Iconsax.clipboard_close,
                color: PotColors.primaryRed,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Belum Ada Riwayat Closing',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: PotColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Laporan closing harian yang telah dikirim akan tercatat dan ditampilkan di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: PotColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 40, color: PotColors.primaryRed),
            const SizedBox(height: 10),
            Text(
              _viewModel.errorMessage ?? 'Gagal memuat riwayat.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: PotColors.textDark),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _viewModel.fetchHistory,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
