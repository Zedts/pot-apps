import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/pengiriman_model.dart';
import '../attendance/attendance_status_badge.dart';
import '../common/app_toast.dart';
import '../common/custom_button.dart';

/// Modal Bottom Sheet displaying detailed shipment manifest with status gating & bookmark action
class PengirimanInspectionSheet extends StatefulWidget {
  final PengirimanModel initialShipment;
  final Future<PengirimanModel> Function(String id) loadDetail;
  final ValueChanged<PengirimanModel> onSelectShipment;
  final FutureOr<void> Function(PengirimanModel updated) onToggleStatus;

  const PengirimanInspectionSheet({
    super.key,
    required this.initialShipment,
    required this.loadDetail,
    required this.onSelectShipment,
    required this.onToggleStatus,
  });

  static Future<void> show(
    BuildContext context, {
    required PengirimanModel initialShipment,
    required Future<PengirimanModel> Function(String id) loadDetail,
    required ValueChanged<PengirimanModel> onSelectShipment,
    required FutureOr<void> Function(PengirimanModel updated) onToggleStatus,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PengirimanInspectionSheet(
        initialShipment: initialShipment,
        loadDetail: loadDetail,
        onSelectShipment: onSelectShipment,
        onToggleStatus: onToggleStatus,
      ),
    );
  }

  @override
  State<PengirimanInspectionSheet> createState() => _PengirimanInspectionSheetState();
}

class _PengirimanInspectionSheetState extends State<PengirimanInspectionSheet> {
  late PengirimanModel _shipment;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _shipment = widget.initialShipment;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final detail = await widget.loadDetail(widget.initialShipment.id);
      if (mounted) {
        setState(() {
          _shipment = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat detail barang: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDraft = _shipment.isDraft;
    final isSelesai = _shipment.isSelesai;
    final isActionDisabled = isDraft || isSelesai || _isLoading;
    final canPick = !isDraft && !isSelesai && !_isLoading;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: PotColors.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: PotColors.warmBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _shipment.uniqueId,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: PotColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      _shipment.formattedCreatedDateTime,
                      style: const TextStyle(
                        fontSize: 11,
                        color: PotColors.textMuted,
                      ),
                    ),
                  ],
                ),
                // Prominent Status Badge
                AttendanceStatusBadge(status: _shipment.status),
              ],
            ),
          ),
          const Divider(color: PotColors.warmBorder, height: 1),

          // Body Content
          Flexible(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: PotColors.primaryRed),
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(_error!, style: const TextStyle(color: PotColors.statusErrorText)),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dispatcher & Stall info
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: PotColors.pureWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: PotColors.warmBorder),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Pengirim',
                                                style: TextStyle(fontSize: 10, color: PotColors.textMuted)),
                                            Text(
                                              _shipment.namaPengirim,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: PotColors.textDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _shipment.isTransfer ? 'Lapak Asal' : 'Lapak Tujuan',
                                              style: const TextStyle(fontSize: 10, color: PotColors.textMuted),
                                            ),
                                            Text(
                                              _shipment.isTransfer
                                                  ? (_shipment.asalLapak?.nama ?? 'Lapak Asal')
                                                  : (_shipment.lapak?.nama ?? 'Lapak'),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: PotColors.textDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_shipment.isTransfer) ...[
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(color: PotColors.warmBorder, height: 1),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Lapak Tujuan',
                                                  style: TextStyle(fontSize: 10, color: PotColors.textMuted)),
                                              Text(
                                                _shipment.lapak?.nama ?? 'Lapak',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: PotColors.textDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Items Manifest
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Daftar Barang Dikirim:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: PotColors.textDark,
                                  ),
                                ),
                                Text(
                                  'Total ${_shipment.qtyKirim} pcs',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: PotColors.primaryRed,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Table of items
                            Container(
                              decoration: BoxDecoration(
                                color: PotColors.pureWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: PotColors.warmBorder),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _shipment.items.length,
                                separatorBuilder: (ctx, i) =>
                                    const Divider(color: PotColors.warmBorder, height: 1),
                                itemBuilder: (ctx, i) {
                                  final item = _shipment.items[i];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.namaProduk,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: PotColors.textDark,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${item.qty} ${item.jenisSatuan}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: PotColors.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Digital Signature Preview Card
                            if (_shipment.ttdPengirimUrl != null &&
                                _shipment.ttdPengirimUrl!.trim().isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: PotColors.pureWhite,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: PotColors.warmBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Iconsax.edit_2, size: 14, color: PotColors.primaryRed),
                                            SizedBox(width: 6),
                                            Text(
                                              'Tanda Tangan Pengirim',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: PotColors.textDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Ketuk untuk perbesar',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: PotColors.primaryRed.withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () => _showFullImageModal(
                                        context,
                                        _shipment.ttdPengirimUrl!,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: double.infinity,
                                        height: 84,
                                        decoration: BoxDecoration(
                                          color: PotColors.bgCream.withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: PotColors.warmBorder),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            _shipment.ttdPengirimUrl!,
                                            fit: BoxFit.contain,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return const Center(
                                                child: SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: PotColors.primaryRed,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Center(
                                                child: Text(
                                                  'Gagal memuat tanda tangan.',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: PotColors.textMuted,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            if (isDraft) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: PotColors.statusWarningBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: PotColors.statusWarningBorder),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 16, color: PotColors.statusWarningText),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Pengiriman berstatus "Draft" belum dapat dipilih. Tunggu hingga status "Dikirim Viar".',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: PotColors.statusWarningText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (isSelesai) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: PotColors.statusSuccessBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: PotColors.statusSuccessBorder),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 16, color: PotColors.statusSuccessText),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Pengiriman telah berstatus "Selesai". Barang sudah selesai diterima.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: PotColors.statusSuccessText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
          ),

          // Bottom Action Bar: Bookmark/Save Icon Button + Pilih Pengiriman Button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: PotColors.warmBorder)),
            ),
            child: Row(
              children: [
                // Icon-Only Bookmark/Save Button (Toggles status & disabled on draft/selesai)
                Tooltip(
                  message: isDraft
                      ? 'Tidak dapat menandai status Draft'
                      : (isSelesai
                          ? 'Pengiriman sudah selesai'
                          : (_shipment.isDiterimaSpg ? 'Batalkan diterima SPG' : 'Tandai diterima SPG')),
                  child: Opacity(
                    opacity: isActionDisabled ? 0.4 : 1.0,
                    child: InkWell(
                      onTap: isActionDisabled ? null : _handleToggleBookmark,
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _shipment.isDiterimaSpg
                              ? PotColors.statusSuccessBg
                              : PotColors.cardCream,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _shipment.isDiterimaSpg
                                ? PotColors.statusSuccessBorder
                                : PotColors.warmBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Iconsax.archive_tick,
                          color: _shipment.isDiterimaSpg
                              ? PotColors.statusSuccessText
                              : (isActionDisabled ? PotColors.textLight : PotColors.primaryRed),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Main Action Button (Pilih Pengiriman) - Disabled on draft
                Expanded(
                  child: CustomButton(
                    label: 'Pilih Pengiriman',
                    icon: Iconsax.box_tick,
                    isDisabled: !canPick,
                    onPressed: !canPick
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            widget.onSelectShipment(_shipment);
                          },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleToggleBookmark() async {
    if (_shipment.isDraft || _shipment.isSelesai || _isLoading) return;

    final isCurrentlyDiterima =
        _shipment.status.toLowerCase() == AppConstants.deliveryDiterimaSPG;
    final nextStatus = isCurrentlyDiterima
        ? AppConstants.deliveryDikirimViar
        : AppConstants.deliveryDiterimaSPG;

    final previous = _shipment;
    final updated = _shipment.copyWith(status: nextStatus);
    setState(() {
      _shipment = updated;
    });

    try {
      await widget.onToggleStatus(updated);

      if (mounted) {
        AppToast.show(
          context,
          message: nextStatus == AppConstants.deliveryDiterimaSPG
              ? 'Status ${_shipment.uniqueId} diubah menjadi Diterima SPG.'
              : 'Status ${_shipment.uniqueId} dikembalikan menjadi Di Jalan.',
          isSuccess: true,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _shipment = previous;
        });
        AppToast.show(
          context,
          message: 'Gagal memperbarui status di server: $e',
          isSuccess: false,
        );
      }
    }
  }

  void _showFullImageModal(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: PotColors.pureWhite,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tanda Tangan Pengirim',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: PotColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          padding: const EdgeInsets.all(48),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: PotColors.primaryRed,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(32),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Iconsax.warning_2, size: 36, color: PotColors.primaryRed),
                              SizedBox(height: 8),
                              Text(
                                'Gagal memuat tanda tangan.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: PotColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.black45,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(ctx).pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.close, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
