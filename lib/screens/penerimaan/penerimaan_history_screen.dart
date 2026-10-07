import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/penerimaan_model.dart';
import '../../widgets/attendance/attendance_status_badge.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/penerimaan/penerimaan_detail_sheet.dart';
import 'repositories/penerimaan_repository_impl.dart';
import 'viewmodels/penerimaan_view_model.dart';

/// Receipt History Archive Screen ("Riwayat Penerimaan") using penerimaan endpoint
class PenerimaanHistoryScreen extends StatefulWidget {
  final PenerimaanViewModel viewModel;

  const PenerimaanHistoryScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<PenerimaanHistoryScreen> createState() => _PenerimaanHistoryScreenState();
}

class _PenerimaanHistoryScreenState extends State<PenerimaanHistoryScreen> {
  final _repository = PenerimaanRepositoryImpl();
  List<PenerimaanModel> _history = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'semua';

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await _repository.getReceiptHistory(
        spgId: widget.viewModel.user?.id,
        lapakId: widget.viewModel.user?.lapakId,
      );
      if (mounted) {
        setState(() {
          _history = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat riwayat penerimaan: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<PenerimaanModel> get _filteredHistory {
    if (_selectedFilter == 'semua') return _history;
    return _history.where((r) => r.status.toLowerCase() == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalSesuai = _history.where((r) => r.isSesuai).length;
    final totalSelisih = _history.where((r) => r.isSelisih).length;

    return Scaffold(
      backgroundColor: PotColors.bgCream,
      appBar: const AppHeader(
        showBackButton: true,
        title: 'Riwayat Penerimaan',
      ),
      body: RefreshIndicator(
        color: PotColors.primaryRed,
        backgroundColor: Colors.white,
        displacement: 40,
        onRefresh: () async {
          await _fetchHistory();
          if (context.mounted) {
            AppToast.show(
              context,
              message: 'Riwayat penerimaan diperbarui.',
              isSuccess: true,
            );
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      label: 'Sesuai',
                      count: totalSesuai,
                      color: PotColors.statusSuccessText,
                      bgColor: PotColors.statusSuccessBg,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSummaryCard(
                      label: 'Selisih',
                      count: totalSelisih,
                      color: PotColors.statusWarningText,
                      bgColor: PotColors.statusWarningBg,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterPill('semua', 'Semua (${_history.length})'),
                    const SizedBox(width: 8),
                    _buildFilterPill('sesuai', 'Sesuai ($totalSesuai)'),
                    const SizedBox(width: 8),
                    _buildFilterPill('selisih', 'Selisih ($totalSelisih)'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Receipts List
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(color: PotColors.primaryRed),
                  ),
                )
              else if (_error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, style: const TextStyle(color: PotColors.statusErrorText)),
                  ),
                )
              else if (_filteredHistory.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  alignment: Alignment.center,
                  child: const Text(
                    'Belum ada data penerimaan pada kategori ini.',
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int index = 0; index < _filteredHistory.length; index++) ...[
                        if (index > 0)
                          const Divider(
                            color: PotColors.warmBorder,
                            height: 1,
                          ),
                        _buildHistoryItem(_filteredHistory[index]),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(PenerimaanModel item) {
    final uniqueId = item.uniqueId ?? item.pengiriman?.uniqueId ?? '#PG-...';

    return InkWell(
      onTap: () {
        PenerimaanDetailSheet.show(
          context,
          receipt: item,
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: PotColors.cardCream,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PotColors.warmBorder),
              ),
              child: const Icon(
                Iconsax.document_text,
                color: PotColors.primaryRed,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        uniqueId,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: PotColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 6),
                      AttendanceStatusBadge(status: item.status),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Diterima: ${item.qtyTerima} pcs • ${item.formattedTanggal}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: PotColors.textMuted,
                    ),
                  ),
                  if (item.catatan.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Catatan: "${item.catatan}"',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: PotColors.textDark,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.notaUrl != null && item.notaUrl!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: PotColors.statusSuccessBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.document,
                  size: 14,
                  color: PotColors.statusSuccessText,
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildSummaryCard({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
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
