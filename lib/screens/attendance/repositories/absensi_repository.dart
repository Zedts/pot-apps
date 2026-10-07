import 'dart:io';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/absensi_model.dart';
import '../../../core/models/lapak_model.dart';

/// Abstract repository contract for employee attendance (absensi) operations.
abstract class AbsensiRepository {
  /// Clock-in attendance (Absen Masuk) with GPS coordinates and optional photo proof.
  Future<AbsensiModel> clockIn({
    required String lapakId,
    required double latitude,
    required double longitude,
    File? photoFile,
    String? keterangan,
    String status = AppConstants.absenHadir,
  });

  /// Uploads attendance photo proof for an existing attendance record (POST /absensi/:id/foto).
  Future<AbsensiModel> uploadPhoto({
    required String absensiId,
    required File photoFile,
  });

  /// Clock-out attendance (Absen Pulang).
  Future<AbsensiModel> clockOut(String absensiId);

  /// Retrieves attendance history with optional filters.
  Future<List<AbsensiModel>> getHistory({
    String? userId,
    String? lapakId,
    String? tanggal,
    String? status,
  });

  /// Retrieves single attendance record detail by ID.
  Future<AbsensiModel> getDetail(String id);

  /// Retrieves today's attendance record for the user, or null if not yet clocked in.
  Future<AbsensiModel?> getTodayAttendance({
    required String userId,
    required String tanggal,
  });

  /// Retrieves stall entity details (including coordinates and radius).
  Future<LapakModel?> getLapak(String lapakId);
}
