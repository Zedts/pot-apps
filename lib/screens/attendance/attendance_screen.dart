import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../widgets/attendance/attendance_action_buttons.dart';
import '../../widgets/attendance/attendance_clock_card.dart';
import '../../widgets/attendance/attendance_history_table.dart';
import '../../widgets/attendance/attendance_izin_dialog.dart';
import '../../widgets/attendance/attendance_map_card.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/common/lapak_info_card.dart';
import '../../widgets/common/proof_photo_upload_card.dart';
import 'attendance_history_screen.dart';
import 'viewmodels/attendance_view_model.dart';

/// Main Attendance Screen (Absen Masuk & Absen Pulang) for SPG and employees.
class AttendanceScreen extends StatefulWidget {
  final UserModel? currentUser;

  const AttendanceScreen({
    super.key,
    this.currentUser,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late final AttendanceViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AttendanceViewModel();
    _viewModel.init(currentUser: widget.currentUser);
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
        return Scaffold(
          backgroundColor: PotColors.bgCream,
          appBar: AppHeader(
            showBackButton: true,
            title: 'Absensi',
            subtitle: _viewModel.formattedCurrentDate,
            trailing: _buildIzinButton(context),
          ),
          body: RefreshIndicator(
            color: PotColors.primaryRed,
            backgroundColor: Colors.white,
            onRefresh: () async {
              await _viewModel.refreshAttendanceData();
              await _viewModel.refreshLocation();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
              child: Column(
                children: [
                  // Stall Location Metadata Card
                  LapakInfoCard(stall: _viewModel.stall),
                  const SizedBox(height: 14),

                  // White Attendance Card Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: PotColors.warmBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 1. Digital Clock & Status Badge
                        AttendanceClockCard(viewModel: _viewModel),
                        const SizedBox(height: 16),

                        // 2. OpenStreetMap Interactive Map with 10m Geofence Circle
                        AttendanceMapCard(viewModel: _viewModel),
                        const SizedBox(height: 16),

                        // 3. Photo Selfie Capture / Cloudinary Preview (Reusable Component)
                        ProofPhotoUploadCard(
                          photoFile: _viewModel.capturedPhoto,
                          networkImageUrl: _viewModel.serverPhotoUrl,
                          isReadOnly: _viewModel.isClockedInToday,
                          title: _viewModel.isClockedInToday ? 'Foto Presensi' : 'Ambil Foto Masuk (Selfie)',
                          subtitle: _viewModel.isClockedInToday ? 'Foto presensi tersimpan' : 'Wajib swafoto di lokasi lapak bertugas',
                          sheetTitle: 'Ambil Foto Masuk',
                          sheetSubtitle: 'Ambil swafoto selfie di lokasi lapak bertugas',
                          statusText: 'Foto Presensi Tersimpan',
                          onCameraTap: _viewModel.capturePhoto,
                          onRemoveTap: _viewModel.clearCapturedPhoto,
                          onDirectTap: _viewModel.capturePhoto,
                        ),
                        const SizedBox(height: 16),

                        // 4. Action Buttons (Absen Masuk / Absen Pulang)
                        AttendanceActionButtons(viewModel: _viewModel),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 5. Bordered 5-Row Recent History Table
                  AttendanceHistoryTable(
                    viewModel: _viewModel,
                    onSeeAllTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => AttendanceHistoryScreen(
                            viewModel: _viewModel,
                          ),
                        ),
                      );
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

  Widget _buildIzinButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await AttendanceIzinDialog.show(context, viewModel: _viewModel);
        if (result == true && context.mounted) {
          AppToast.show(
            context,
            message: 'Pengajuan izin berhasil dicatat.',
            isSuccess: true,
          );
        }
      },
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: PotColors.cardCream,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: PotColors.warmBorder),
          boxShadow: [
            BoxShadow(
              color: PotColors.primaryRed.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.document_text,
              size: 15,
              color: PotColors.primaryRed,
            ),
            SizedBox(width: 5),
            Text(
              'Izin',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: PotColors.primaryRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
