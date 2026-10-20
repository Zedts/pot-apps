import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/activity_history_model.dart';
import '../../../core/models/absensi_model.dart';
import '../../../core/models/lapak_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/activity_history_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/viewmodels/base_view_model.dart';
import '../repositories/absensi_repository.dart';
import '../repositories/absensi_repository_impl.dart';

/// ViewModel managing state, timers, GPS tracking, camera capture,
/// and attendance operations (Absen Masuk, Absen Pulang, History).
class AttendanceViewModel extends BaseViewModel {
  final AbsensiRepository _repository;
  final LocationService _locationService;
  final CameraService _cameraService;
  final ActivityHistoryService _activityHistoryService;

  UserModel? _user;
  LapakModel? _stall;
  AbsensiModel? _todayRecord;
  List<AbsensiModel> _history = [];

  DateTime _currentTime;
  Timer? _clockTimer;
  final DateTime Function()? _currentTimeProvider;

  Position? _currentPosition;
  double? _distanceToStallMeters;
  bool _isWithinRadius = false;
  bool _isLoadingLocation = false;
  bool _isLocationServiceEnabled = true;
  bool _isLocationPermissionGranted = true;
  String? _locationError;

  File? _capturedPhoto;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  AttendanceViewModel({
    AbsensiRepository? repository,
    LocationService? locationService,
    CameraService? cameraService,
    ActivityHistoryService? activityHistoryService,
    DateTime Function()? currentTimeProvider,
  })  : _repository = repository ?? AbsensiRepositoryImpl(),
        _locationService = locationService ?? LocationService(),
        _cameraService = cameraService ?? CameraService(),
        _activityHistoryService = activityHistoryService ?? ActivityHistoryService(),
        _currentTimeProvider = currentTimeProvider,
        _currentTime = currentTimeProvider != null ? currentTimeProvider() : DateTime.now();

  // Getters
  UserModel? get user => _user;
  LapakModel? get stall => _stall;
  AbsensiModel? get todayRecord => _todayRecord;
  List<AbsensiModel> get history => _history;
  List<AbsensiModel> get recentHistory => _history.take(5).toList();

  DateTime get currentTime => _currentTime;
  Position? get currentPosition => _currentPosition;
  double? get distanceToStallMeters => _distanceToStallMeters;
  bool get isWithinRadius => _isWithinRadius;
  bool get isLoadingLocation => _isLoadingLocation;
  bool get isLocationServiceEnabled => _isLocationServiceEnabled;
  bool get isLocationPermissionGranted => _isLocationPermissionGranted;
  bool get hasStallLocation => _stall != null && _stall!.hasCoordinates;
  String? get locationError => _locationError;

  File? get capturedPhoto => _capturedPhoto;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool get isClockedInToday => _todayRecord != null;
  bool get isClockedOutToday => _todayRecord != null && _todayRecord!.isClockedOut;
  bool get isIzinToday => _todayRecord?.status.toLowerCase() == AppConstants.absenIzin;

  /// Photo URL from today's saved record, or null
  String? get serverPhotoUrl => _todayRecord?.fotoMasukUrl;

  /// Effective shift assigned to user, or null if unassigned
  String? get userShift => _user?.shift;

  /// Whether user has a designated shift assigned
  bool get hasShift => _user?.hasShift ?? false;

  /// Human-readable shift name: "Pagi", "Siang", "Long Shift", or "Belum Ditentukan"
  String get userShiftLabel {
    if (_user?.isShiftLong == true) return 'Long Shift';
    if (_user?.isShiftSiang == true) return 'Siang';
    if (_user?.isShiftPagi == true) return 'Pagi';
    return 'Belum Ditentukan';
  }

  /// Shift start and end hours [start, end], e.g. ["08:00", "16:00"]
  List<String> get shiftHours {
    final shift = userShift;
    if (shift == null) return AppConstants.defaultShiftHours(null);
    if (_stall != null) {
      return _stall!.getShiftHours(shift);
    }
    return AppConstants.defaultShiftHours(shift);
  }

  /// Shift schedule display string, e.g. "08:00 - 16:00"
  String get shiftScheduleDisplay {
    if (!hasShift) return '--:-- - --:--';
    final hours = shiftHours;
    return '${hours[0]} - ${hours[1]}';
  }

  /// Scheduled clock-in start time, e.g. "08:00"
  String get scheduledClockInTime => shiftHours[0];

  /// Scheduled clock-out end time, e.g. "16:00"
  String get scheduledClockOutTime => shiftHours[1];

  int get scheduledClockInMinutes {
    final parts = scheduledClockInTime.split(':');
    final h = int.tryParse(parts[0]) ?? 8;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return h * 60 + m;
  }

  int get scheduledClockOutMinutes {
    final parts = scheduledClockOutTime.split(':');
    final h = int.tryParse(parts[0]) ?? 16;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return h * 60 + m;
  }

  int get currentMinutes => _currentTime.hour * 60 + _currentTime.minute;

  int get earlyWindowOpenMinutes =>
      scheduledClockInMinutes - AppConstants.earlyClockInWindowMinutes;

  String get earlyWindowOpenTimeStr {
    final open = earlyWindowOpenMinutes;
    final normalized = (open % 1440 + 1440) % 1440;
    final h = (normalized ~/ 60).toString().padLeft(2, '0');
    final m = (normalized % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Checks if clock-in is attempted before the 3-hour early window opens (< T_start - 180m)
  bool get isClockInTooEarly {
    if (!hasShift) return false;
    return currentMinutes < earlyWindowOpenMinutes;
  }

  /// Checks if the clock-in window for the user's shift has expired (> scheduled end time)
  bool get isClockInExpired {
    if (!hasShift) return false;
    return currentMinutes > scheduledClockOutMinutes;
  }

  /// Checks if clock-in is within the valid active window ([T_start - 180m, T_end])
  bool get isClockInAvailable =>
      hasShift && !isClockInTooEarly && !isClockInExpired;

  /// Detects if there is an unclosed session from previous dates
  AbsensiModel? get unclosedPreviousSession {
    for (final rec in _history) {
      if (rec.id != _todayRecord?.id &&
          rec.jamMasuk != null &&
          rec.jamPulang == null &&
          rec.status.toLowerCase() != AppConstants.absenIzin) {
        return rec;
      }
    }
    return null;
  }

  bool get hasUnclosedPreviousSession => unclosedPreviousSession != null;

  /// Formatted current time string: "08:55" (no seconds)
  String get formattedCurrentTime {
    final h = _currentTime.hour.toString().padLeft(2, '0');
    final m = _currentTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Formatted current date string: "Kamis, 10 September 2026"
  String get formattedCurrentDate => DateFormatter.formatFullDate(_currentTime);

  /// Initializes clock ticker, user profile, stall coordinates, and today's status.
  Future<void> init({UserModel? currentUser}) async {
    _startClockTimer();

    _user = currentUser ?? await TokenStorage.getUser();
    if (_user == null) {
      _errorMessage = 'Sesi pengguna tidak valid.';
      notifyListeners();
      return;
    }

    // 1. Load stall information
    if (_user!.lapakId != null && _user!.lapakId!.trim().isNotEmpty) {
      _stall = await _repository.getLapak(_user!.lapakId!.trim());
    }

    // 2. Fetch today's attendance & full history
    await refreshAttendanceData();

    // 3. Acquire live GPS location
    await refreshLocation();
  }

  void _startClockTimer() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _currentTime = _currentTimeProvider != null ? _currentTimeProvider() : DateTime.now();
      notifyListeners();
    });
  }

  /// Reloads today's attendance record and historical archive from backend.
  Future<void> refreshAttendanceData() async {
    _user ??= await TokenStorage.getUser();
    if (_user == null) return;
    try {
      final now = _currentTimeProvider != null ? _currentTimeProvider() : DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final results = await Future.wait([
        _repository.getTodayAttendance(userId: _user!.id, tanggal: todayStr),
        _repository.getHistory(userId: _user!.id),
      ]);

      _todayRecord = results[0] as AbsensiModel?;
      _history = (results[1] as List<AbsensiModel>?) ?? [];
      notifyListeners();
    } catch (e) {
      debugPrint('[AttendanceViewModel] Failed to refresh attendance data: $e');
    }
  }

  /// Refreshes current GPS position and recalculates distance to stall perimeter.
  Future<void> refreshLocation() async {
    _isLoadingLocation = true;
    _locationError = null;
    notifyListeners();

    try {
      _isLocationServiceEnabled = await _locationService.isServiceEnabled();
      if (!_isLocationServiceEnabled) {
        _locationError = 'Layanan GPS tidak aktif. Silakan aktifkan GPS perangkat.';
        _isLoadingLocation = false;
        notifyListeners();
        return;
      }

      _isLocationPermissionGranted = await _locationService.checkAndRequestPermission();
      if (!_isLocationPermissionGranted) {
        _locationError = 'Izin lokasi belum diberikan.';
        _isLoadingLocation = false;
        notifyListeners();
        return;
      }

      final pos = await _locationService.getCurrentPosition();
      if (pos != null) {
        _currentPosition = pos;
        _recalculateGeofence();
      } else {
        _locationError = 'Gagal mengakses lokasi GPS.';
      }
    } catch (e) {
      _locationError = 'Error mendeteksi lokasi: $e';
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  void _recalculateGeofence() {
    if (_currentPosition == null || _stall == null || !_stall!.hasCoordinates) {
      _distanceToStallMeters = null;
      _isWithinRadius = false;
      return;
    }

    final distance = _locationService.calculateDistance(
      startLatitude: _currentPosition!.latitude,
      startLongitude: _currentPosition!.longitude,
      endLatitude: _stall!.latitude!,
      endLongitude: _stall!.longitude!,
    );

    _distanceToStallMeters = distance;
    _isWithinRadius = distance <= _stall!.radiusMeter;
  }

  /// Launches the front camera to capture a selfie proof.
  Future<void> capturePhoto() async {
    final photo = await _cameraService.takeSelfiePhoto();
    if (photo != null) {
      _capturedPhoto = photo;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Clears locally captured photo.
  void clearCapturedPhoto() {
    _capturedPhoto = null;
    notifyListeners();
  }

  /// Submits Clock-in (Absen Masuk).
  Future<bool> clockIn({String? keterangan}) async {
    if (_isSubmitting) return false;
    _errorMessage = null;
    _successMessage = null;

    if (!hasShift) {
      _errorMessage = 'Anda belum memiliki jadwal shift yang ditentukan. Hubungi Admin.';
      notifyListeners();
      return false;
    }

    if (hasUnclosedPreviousSession) {
      _errorMessage =
          'Anda memiliki presensi sebelumnya yang belum melakukan absen pulang. Harap selesaikan absen pulang terlebih dahulu.';
      notifyListeners();
      return false;
    }

    if (_stall == null) {
      _errorMessage = 'Anda belum ditugaskan ke lapak manapun.';
      notifyListeners();
      return false;
    }

    if (!_stall!.hasCoordinates) {
      _errorMessage = 'Lokasi lapak belum ditentukan oleh Admin. Presensi dinonaktifkan.';
      notifyListeners();
      return false;
    }

    if (isClockInTooEarly) {
      _errorMessage =
          'Presensi masuk untuk shift $userShiftLabel belum dibuka. Presensi dibuka mulai pukul $earlyWindowOpenTimeStr WIB.';
      notifyListeners();
      return false;
    }

    if (isClockInExpired) {
      _errorMessage =
          'Jadwal kerja untuk shift $userShiftLabel telah berakhir pada pukul $scheduledClockOutTime. Presensi masuk tidak dapat dicatat.';
      notifyListeners();
      return false;
    }

    if (_currentPosition == null) {
      await refreshLocation();
      if (_currentPosition == null) {
        _errorMessage = 'Lokasi GPS belum terdeteksi. Silakan aktifkan GPS Anda.';
        notifyListeners();
        return false;
      }
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      // Determine punctual vs late status (dynamic shift cutoff)
      // Clocking in <= scheduledClockInMinutes (within 3h early window): Hadir
      // Clocking in > scheduledClockInMinutes: Terlambat
      final isLate = currentMinutes > scheduledClockInMinutes;
      final status = isLate ? AppConstants.absenTerlambat : AppConstants.absenHadir;

      final record = await _repository.clockIn(
        lapakId: _stall!.id,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        photoFile: _capturedPhoto,
        keterangan: keterangan,
        status: status,
      );

      _todayRecord = record;
      await _activityHistoryService.record(
        ActivityHistoryModel(
          userId: _user!.id,
          lapakId: _stall!.id,
          activityType: AppConstants.activityClockIn,
          title: 'Presensi Masuk',
          description: 'Status ${record.statusDisplay}',
          occurredAt: record.jamMasuk ?? DateTime.now(),
          referenceId: record.id,
        ),
      );
      _capturedPhoto = null;
      _successMessage = 'Presensi masuk berhasil dicatat.';
      await refreshAttendanceData();
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        // Daily uniqueness conflict: user already clocked in
        _errorMessage = 'Anda sudah melakukan presensi masuk hari ini.';
        await refreshAttendanceData();
      } else {
        _errorMessage = e.userMessage;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat presensi masuk: $e';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Submits Clock-out (Absen Pulang).
  Future<bool> clockOut() async {
    if (_isSubmitting) return false;
    final targetRecord = _todayRecord ?? unclosedPreviousSession;
    if (targetRecord == null) {
      _errorMessage = 'Belum ada data presensi masuk yang perlu diselesaikan.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.clockOut(targetRecord.id);
      if (_todayRecord?.id == targetRecord.id) {
        _todayRecord = updated;
      }
      await _activityHistoryService.record(
        ActivityHistoryModel(
          userId: _user!.id,
          lapakId: _stall?.id,
          activityType: AppConstants.activityClockOut,
          title: 'Presensi Pulang',
          description: 'Presensi pulang berhasil dicatat',
          occurredAt: updated.jamPulang ?? DateTime.now(),
          referenceId: updated.id,
        ),
      );
      _successMessage = 'Presensi pulang berhasil dicatat. Terima kasih atas kerja keras Anda!';
      await refreshAttendanceData();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat presensi pulang: $e';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Submits Izin / Sakit request.
  Future<bool> submitIzin({required String keterangan}) async {
    if (_isSubmitting) return false;

    if (!hasShift) {
      _errorMessage = 'Anda belum memiliki jadwal shift yang ditentukan. Hubungi Admin.';
      notifyListeners();
      return false;
    }

    if (_stall == null) {
      _errorMessage = 'Anda belum ditugaskan ke lapak manapun.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final lat = _currentPosition?.latitude ?? (_stall?.latitude ?? 0.0);
      final lng = _currentPosition?.longitude ?? (_stall?.longitude ?? 0.0);

      final record = await _repository.clockIn(
        lapakId: _stall!.id,
        latitude: lat,
        longitude: lng,
        photoFile: _capturedPhoto,
        keterangan: keterangan,
        status: AppConstants.absenIzin,
      );

      _todayRecord = record;
      _capturedPhoto = null;
      _successMessage = 'Pengajuan izin berhasil dicatat.';
      await refreshAttendanceData();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat mengajukan izin: $e';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Fetches attendance detail by ID for the modal inspection sheet.
  /// (Explicitly requested by user: "also the get detail by id")
  Future<AbsensiModel?> getAttendanceDetail(String id) async {
    try {
      return await _repository.getDetail(id);
    } catch (e) {
      debugPrint('[AttendanceViewModel] Error fetching detail for $id: $e');
      return null;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }
}
