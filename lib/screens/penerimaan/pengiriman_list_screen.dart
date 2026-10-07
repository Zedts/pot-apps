import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/pengiriman_model.dart';
import '../../widgets/attendance/attendance_status_badge.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/penerimaan/pengiriman_inspection_sheet.dart';
import 'viewmodels/penerimaan_view_model.dart';

/// Full Shipments Archive Screen ("Lihat Pengiriman")
class PengirimanListScreen extends StatefulWidget {
  final PenerimaanViewModel viewModel;

  const PengirimanListScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<PengirimanListScreen> createState() => _PengirimanListScreenState();
}

class _PengirimanListScreenState extends State<PengirimanListScreen> {
  String _selectedFilter = 'semua';

  List<PengirimanModel> _filterShipments(List<PengirimanModel> list) {
    if (_selectedFilter == 'semua') {
      return list;
    }
    return list.where((s) => s.status.toLowerCase() == _selectedFilter).toList();
  }

  void _openInspectionSheet(PengirimanModel shipment) {
    PengirimanInspectionSheet.show(
      context,
      initialShipment: shipment,
      loadDetail: widget.viewModel.getShipmentDetail,
      onSelectShipment: (detailed) {
        widget.viewModel.selectShipment(detailed);
        Navigator.of(context).pop(); // Return to main PenerimaanScreen
      },
      onToggleStatus: (updated) async {
        await widget.viewModel.updateShipment(updated);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final all = widget.viewModel.allShipments;
        final filtered = _filterShipments(all);

        final totalDikirim = all.where((s) => s.isDikirimViar).length;
        final totalDraft = all.where((s) => s.isDraft).length;
        final totalDiterima = all.where((s) => s.isDiterimaSpg).length;
        final totalSelesai = all.where((s) => s.isSelesai).length;

        return Scaffold(
          backgroundColor: PotColors.bgCream,
          appBar: const AppHeader(
            showBackButton: true,
            title: 'Daftar Pengiriman',
          ),
          body: RefreshIndicator(
            color: PotColors.primaryRed,
            backgroundColor: Colors.white,
            displacement: 40,
            onRefresh: () async {
              await widget.viewModel.refreshShipments();
              if (context.mounted) {
                AppToast.show(
                  context,
                  message: 'Data pengiriman berhasil diperbarui.',
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
                  // Filter Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterPill('semua', 'Semua (${all.length})'),
                        const SizedBox(width: 8),
                        _buildFilterPill('dikirim_viar', 'Di Jalan ($totalDikirim)'),
                        const SizedBox(width: 8),
                        _buildFilterPill('draft', 'Draft ($totalDraft)'),
                        const SizedBox(width: 8),
                        _buildFilterPill('diterima_spg', 'Diterima SPG ($totalDiterima)'),
                        const SizedBox(width: 8),
                        _buildFilterPill('selesai', 'Selesai ($totalSelesai)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Shipments List
                  if (filtered.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      alignment: Alignment.center,
                      child: const Text(
                        'Tidak ada pengiriman pada kategori ini.',
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
                          for (int index = 0; index < filtered.length; index++) ...[
                            if (index > 0)
                              const Divider(
                                color: PotColors.warmBorder,
                                height: 1,
                              ),
                            _buildShipmentItem(filtered[index]),
                          ],
                        ],
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

  Widget _buildShipmentItem(PengirimanModel item) {
    final creatorName = item.creator?['nama'] ?? 'Ekspedisi Pusat';

    return InkWell(
      onTap: () => _openInspectionSheet(item),
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
                Iconsax.truck,
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
                        item.uniqueId,
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
                    'Pusat • $creatorName (${item.formattedJam})',
                    style: const TextStyle(
                      fontSize: 11,
                      color: PotColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '📦 ${item.totalItems} Jenis (${item.qtyKirim} pcs)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: PotColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Iconsax.arrow_right_3,
              size: 16,
              color: PotColors.textLight,
            ),
          ],
        ),
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
