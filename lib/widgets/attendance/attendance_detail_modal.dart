import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/absensi_model.dart';
import '../../screens/attendance/viewmodels/attendance_view_model.dart';
import 'attendance_status_badge.dart';

/// Modal bottom sheet displaying detailed attendance record fetched via GET /api/v1/absensi/:id.
class AttendanceDetailModal extends StatefulWidget {
  final String absensiId;
  final AbsensiModel? initialRecord;
  final AttendanceViewModel viewModel;

  const AttendanceDetailModal({
    super.key,
    required this.absensiId,
    this.initialRecord,
    required this.viewModel,
  });

  static void show(
    BuildContext context, {
    required String absensiId,
    AbsensiModel? initialRecord,
    required AttendanceViewModel viewModel,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AttendanceDetailModal(
        absensiId: absensiId,
        initialRecord: initialRecord,
        viewModel: viewModel,
      ),
    );
  }

  @override
  State<AttendanceDetailModal> createState() => _AttendanceDetailModalState();
}

class _AttendanceDetailModalState extends State<AttendanceDetailModal> {
  late AbsensiModel? _record;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _record = widget.initialRecord;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    if (_record == null) {
      setState(() => _isLoading = true);
    }
    final detail = await widget.viewModel.getAttendanceDetail(widget.absensiId);
    if (mounted && detail != null) {
      setState(() {
        _record = detail;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: PotColors.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PotColors.warmBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detail Presensi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: PotColors.textDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: PotColors.cardCream,
                      shape: BoxShape.circle,
                      border: Border.all(color: PotColors.warmBorder),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.close, size: 18, color: PotColors.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoading && _record == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: PotColors.primaryRed),
                ),
              )
            else if (_record == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'Gagal memuat detail presensi.',
                    style: TextStyle(color: PotColors.textMuted),
                  ),
                ),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status and Date Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: PotColors.warmBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_record!.dayNameIndo}, ${_record!.formattedTanggal}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: PotColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _record!.stallOrUserSubtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: PotColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            AttendanceStatusBadge(
                              status: _record!.status,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Time Metrics
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              icon: Iconsax.login,
                              title: 'Jam Masuk',
                              value: _record!.formattedJamMasuk,
                              color: PotColors.statusSuccessText,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMetricTile(
                              icon: Iconsax.logout,
                              title: 'Jam Pulang',
                              value: _record!.formattedJamPulang,
                              color: PotColors.primaryRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Stall & Geolocation Details
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: PotColors.warmBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Iconsax.shop, size: 16, color: PotColors.primaryRed),
                                SizedBox(width: 6),
                                Text(
                                  'Lokasi Lapak',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: PotColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _record!.lapak?.nama ?? 'Lapak Tidak Diketahui',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: PotColors.textDark,
                              ),
                            ),
                            if (_record!.lapak?.lokasi.isNotEmpty ?? false) ...[
                              const SizedBox(height: 2),
                              Text(
                                _record!.lapak!.lokasi,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: PotColors.textMuted,
                                ),
                              ),
                            ],
                            if (_record!.lokasiMasuk != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Koordinat Masuk: ${_record!.lokasiMasuk!.latitude.toStringAsFixed(6)}, ${_record!.lokasiMasuk!.longitude.toStringAsFixed(6)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: PotColors.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Photo Section
                      if (_record!.fotoMasukUrl != null && _record!.fotoMasukUrl!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: PotColors.warmBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Iconsax.camera, size: 16, color: PotColors.primaryRed),
                                  SizedBox(width: 6),
                                  Text(
                                    'Foto Bukti Presensi',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: PotColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  _record!.fotoMasukUrl!,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (ctx, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(color: PotColors.primaryRed),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Notes / Keterangan
                      if (_record!.keterangan.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: PotColors.warmBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Keterangan',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: PotColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _record!.keterangan,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: PotColors.textMuted,
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
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PotColors.warmBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: PotColors.textMuted),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension _AbsensiHelper on AbsensiModel {
  String get stallOrUserSubtitle {
    if (lapak != null && lapak!.nama.isNotEmpty) {
      return lapak!.nama;
    }
    return user?.nama ?? 'Karyawan';
  }
}
