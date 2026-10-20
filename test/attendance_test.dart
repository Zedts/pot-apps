import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pot_apps/core/models/absensi_model.dart';
import 'package:pot_apps/core/models/lapak_model.dart';
import 'package:pot_apps/core/models/user_model.dart';
import 'package:pot_apps/core/network/api_error_mapper.dart';
import 'package:pot_apps/core/network/api_exception.dart';
import 'package:pot_apps/core/services/location_service.dart';
import 'package:pot_apps/screens/attendance/repositories/absensi_repository.dart';
import 'package:pot_apps/screens/attendance/viewmodels/attendance_view_model.dart';
import 'dart:io';

class FakeLocationService extends LocationService {
  @override
  Future<bool> isServiceEnabled() async => true;

  @override
  Future<bool> checkAndRequestPermission() async => true;

  @override
  Future<Position?> getCurrentPosition() async {
    return Position(
      latitude: -7.792849,
      longitude: 110.365842,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }
}

class FakeAbsensiRepository implements AbsensiRepository {
  AbsensiModel? mockTodayRecord;
  List<AbsensiModel> mockHistory = [];
  LapakModel? mockLapak;
  bool shouldThrow409OnClockIn = false;
  int uploadPhotoCallCount = 0;
  int clockOutCallCount = 0;

  @override
  Future<AbsensiModel> clockIn({
    required String lapakId,
    required double latitude,
    required double longitude,
    File? photoFile,
    String? keterangan,
    String status = 'hadir',
  }) async {
    if (shouldThrow409OnClockIn) {
      throw const ApiException(
        statusCode: 409,
        rawMessage: 'User already clocked in today.',
        userMessage: 'Anda sudah melakukan presensi masuk hari ini.',
      );
    }
    var created = AbsensiModel(
      id: 'absen-101',
      tanggal: '2026-10-07',
      jamMasuk: DateTime(2026, 10, 7, 8, 55),
      lokasiMasuk: GeolocationPoint(latitude: latitude, longitude: longitude),
      status: status,
      keterangan: keterangan ?? '',
      lapak: mockLapak,
    );
    if (photoFile != null) {
      created = await uploadPhoto(absensiId: created.id, photoFile: photoFile);
    }
    mockTodayRecord = created;
    mockHistory.insert(0, created);
    return created;
  }

  @override
  Future<AbsensiModel> uploadPhoto({
    required String absensiId,
    required File photoFile,
  }) async {
    uploadPhotoCallCount++;
    final updated = AbsensiModel(
      id: absensiId,
      tanggal: mockTodayRecord?.tanggal ?? '2026-10-07',
      jamMasuk: mockTodayRecord?.jamMasuk ?? DateTime(2026, 10, 7, 8, 55),
      jamPulang: mockTodayRecord?.jamPulang,
      status: mockTodayRecord?.status ?? 'hadir',
      keterangan: mockTodayRecord?.keterangan ?? '',
      lokasiMasuk: mockTodayRecord?.lokasiMasuk,
      fotoMasukUrl: 'https://res.cloudinary.com/demo/image/upload/sample_uploaded.jpg',
      lapak: mockLapak,
    );
    mockTodayRecord = updated;
    return updated;
  }

  @override
  Future<AbsensiModel> clockOut(String absensiId) async {
    clockOutCallCount++;
    final updated = AbsensiModel(
      id: absensiId,
      tanggal: '2026-10-07',
      jamMasuk: mockTodayRecord?.jamMasuk ?? DateTime(2026, 10, 7, 8, 55),
      jamPulang: DateTime(2026, 10, 7, 17, 0),
      status: mockTodayRecord?.status ?? 'hadir',
      lapak: mockLapak,
    );
    mockTodayRecord = updated;
    return updated;
  }

  @override
  Future<List<AbsensiModel>> getHistory({
    String? userId,
    String? lapakId,
    String? tanggal,
    String? status,
  }) async {
    return mockHistory;
  }

  @override
  Future<AbsensiModel> getDetail(String id) async {
    return mockHistory.firstWhere(
      (item) => item.id == id,
      orElse: () => AbsensiModel(
        id: id,
        tanggal: '2026-10-07',
        status: 'hadir',
        lapak: mockLapak,
      ),
    );
  }

  @override
  Future<AbsensiModel?> getTodayAttendance({
    required String userId,
    required String tanggal,
  }) async {
    return mockTodayRecord;
  }

  @override
  Future<LapakModel?> getLapak(String lapakId) async {
    return mockLapak;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LapakModel Unit Tests', () {
    test('Default radius_meter is 25 when omitted or null', () {
      final json = {
        'id': 'lapak-01',
        'nama': 'Lapak Malioboro',
        'lokasi': 'Jl. Malioboro No. 45',
      };
      final model = LapakModel.fromJson(json);

      expect(model.id, 'lapak-01');
      expect(model.radiusMeter, 25);
      expect(model.hasCoordinates, false);
      expect(model.latitude, isNull);
      expect(model.longitude, isNull);
    });

    test('Custom radius_meter and coordinates are parsed correctly', () {
      final json = {
        'id': 'lapak-02',
        'nama': 'Lapak Tugu',
        'lokasi': 'Dekat Tugu Jogja',
        'latitude': -7.782849,
        'longitude': 110.367842,
        'radius_meter': 50,
      };
      final model = LapakModel.fromJson(json);

      expect(model.radiusMeter, 50);
      expect(model.hasCoordinates, true);
      expect(model.latitude, -7.782849);
      expect(model.longitude, 110.367842);
    });

    test('Default shifts are 08:00-16:00 (pagi), 13:00-21:00 (siang), and 08:00-20:00 (long) when omitted', () {
      final json = {
        'id': 'lapak-01',
        'nama': 'Lapak Malioboro',
        'lokasi': 'Jl. Malioboro No. 45',
      };
      final model = LapakModel.fromJson(json);

      expect(model.shiftPagi, ['08:00', '16:00']);
      expect(model.shiftSiang, ['13:00', '21:00']);
      expect(model.shiftLong, ['08:00', '20:00']);
      expect(model.getShiftHours('pagi'), ['08:00', '16:00']);
      expect(model.getShiftHours('siang'), ['13:00', '21:00']);
      expect(model.getShiftHours('long_shift'), ['08:00', '20:00']);
      expect(model.formatShiftHours('pagi'), '08:00 - 16:00');
      expect(model.formatShiftHours('siang'), '13:00 - 21:00');
      expect(model.formatShiftHours('long_shift'), '08:00 - 20:00');
    });

    test('Custom shift hours are parsed properly', () {
      final json = {
        'id': 'lapak-03',
        'nama': 'Lapak Stasiun',
        'lokasi': 'Stasiun Tugu',
        'shift_pagi': ['07:30', '15:30'],
        'shift_siang': ['14:00', '22:00'],
        'shift_long': ['07:30', '19:30'],
      };
      final model = LapakModel.fromJson(json);

      expect(model.shiftPagi, ['07:30', '15:30']);
      expect(model.shiftSiang, ['14:00', '22:00']);
      expect(model.shiftLong, ['07:30', '19:30']);
      expect(model.getShiftHours('pagi'), ['07:30', '15:30']);
      expect(model.getShiftHours('siang'), ['14:00', '22:00']);
      expect(model.getShiftHours('long_shift'), ['07:30', '19:30']);
    });
  });

  group('UserModel Shift Unit Tests', () {
    test('Shift is null when omitted from JSON', () {
      final json = {
        'id': 'user-01',
        'nama': 'Siti SPG',
        'username': 'siti',
        'email': 'siti@pot.com',
        'role': 'spg',
      };
      final model = UserModel.fromJson(json);
      expect(model.shift, isNull);
      expect(model.hasShift, false);
      expect(model.isShiftPagi, false);
      expect(model.isShiftSiang, false);
      expect(model.isShiftLong, false);
      expect(model.shiftDisplay, '-');
      expect(model.shiftFullDisplay, 'Belum Ditentukan');
    });

    test('Custom shift siang is parsed correctly', () {
      final json = {
        'id': 'user-02',
        'nama': 'Budi SPG',
        'username': 'budi',
        'email': 'budi@pot.com',
        'role': 'spg',
        'shift': 'siang',
      };
      final model = UserModel.fromJson(json);
      expect(model.shift, 'siang');
      expect(model.hasShift, true);
      expect(model.isShiftPagi, false);
      expect(model.isShiftSiang, true);
      expect(model.isShiftLong, false);
      expect(model.shiftDisplay, 'Siang');
      expect(model.shiftFullDisplay, 'Shift Siang');
    });

    test('Custom shift long_shift is parsed correctly', () {
      final json = {
        'id': 'user-03',
        'nama': 'Citra SPG',
        'username': 'citra',
        'email': 'citra@pot.com',
        'role': 'spg',
        'shift': 'long_shift',
      };
      final model = UserModel.fromJson(json);
      expect(model.shift, 'long_shift');
      expect(model.hasShift, true);
      expect(model.isShiftPagi, false);
      expect(model.isShiftSiang, false);
      expect(model.isShiftLong, true);
      expect(model.shiftDisplay, 'Long Shift');
      expect(model.shiftFullDisplay, 'Long Shift');
    });
  });

  group('AbsensiModel Unit Tests', () {
    test('Formats times and dates with Indonesian day names correctly', () {
      final model = AbsensiModel(
        id: 'absen-1',
        tanggal: '2026-10-08',
        jamMasuk: DateTime(2026, 10, 8, 8, 30),
        jamPulang: DateTime(2026, 10, 8, 17, 15),
        status: 'hadir',
      );

      expect(model.formattedJamMasuk, '08:30');
      expect(model.formattedJamPulang, '17:15');
      expect(model.dayNameIndo, 'Kamis');
      expect(model.statusDisplay, 'Tepat Waktu');
      expect(model.isClockedOut, true);
    });

    test('Parses from full JSON payload with nested stall and coordinates', () {
      final json = {
        'id': 'absen-2',
        'tanggal': '2026-10-09',
        'jam_masuk': '2026-10-09T09:15:00.000Z',
        'jam_pulang': null,
        'status': 'terlambat',
        'lokasi_masuk': {
          'latitude': -7.7928,
          'longitude': 110.3658,
        },
        'foto_masuk_url': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        'lapak': {
          'id': 'lapak-01',
          'nama': 'Lapak 1 Malioboro',
          'lokasi': 'Malioboro',
          'latitude': -7.7928,
          'longitude': 110.3658,
          'radius_meter': 10,
        },
      };

      final model = AbsensiModel.fromJson(json);
      expect(model.statusDisplay, 'Terlambat');
      expect(model.isClockedOut, false);
      expect(model.fotoMasukUrl, isNotNull);
      expect(model.lokasiMasuk?.latitude, -7.7928);
      expect(model.lapak?.radiusMeter, 10);
    });

    test('Parses shift_spg and shift_lapak correctly', () {
      final json = {
        'id': 'absen-3',
        'tanggal': '2026-10-14',
        'jam_masuk': '2026-10-14T01:00:00.000Z',
        'status': 'hadir',
        'shift_spg': 'siang',
        'shift_lapak': {
          'lapak_id': 'lapak-01',
          'shift_pagi': ['08:00', '16:00'],
          'shift_siang': ['13:00', '21:00'],
        },
      };

      final model = AbsensiModel.fromJson(json);
      expect(model.shiftSpg, 'siang');
      expect(model.isShiftSiang, true);
      expect(model.isShiftPagi, false);
      expect(model.isShiftLong, false);
      expect(model.shiftDisplay, 'Siang');
      expect(model.shiftLapak?.lapakId, 'lapak-01');
      expect(model.shiftLapak?.shiftSiang, ['13:00', '21:00']);
      expect(model.resolvedShiftHours, ['13:00', '21:00']);
    });

    test('Parses shift_spg long_shift and resolves shiftLong from lapak', () {
      final json = {
        'id': 'absen-4',
        'tanggal': '2026-10-15',
        'jam_masuk': '2026-10-15T01:00:00.000Z',
        'status': 'hadir',
        'shift_spg': 'long_shift',
        'shift_lapak': {
          'lapak_id': 'lapak-01',
          'shift_pagi': ['08:00', '16:00'],
          'shift_siang': ['13:00', '21:00'],
          'shift_long': ['08:00', '20:00'],
        },
      };

      final model = AbsensiModel.fromJson(json);
      expect(model.shiftSpg, 'long_shift');
      expect(model.isShiftLong, true);
      expect(model.isShiftPagi, false);
      expect(model.isShiftSiang, false);
      expect(model.shiftDisplay, 'Long Shift');
      expect(model.shiftLapak?.shiftLong, ['08:00', '20:00']);
      expect(model.resolvedShiftHours, ['08:00', '20:00']);
    });
  });

  group('AttendanceViewModel MVVM Tests', () {
    late FakeAbsensiRepository fakeRepo;
    late FakeLocationService fakeLocation;
    late UserModel testUser;
    late LapakModel testStall;

    setUp(() {
      fakeRepo = FakeAbsensiRepository();
      fakeLocation = FakeLocationService();
      testUser = const UserModel(
        id: 'user-01',
        nama: 'Ahmad SPG',
        username: 'ahmad_spg',
        email: 'ahmad@pot.com',
        role: 'spg',
        lapakId: 'lapak-01',
        shift: 'pagi',
        noHp: '081234567890',
        status: 'active',
        authProvider: 'local',
      );
      testStall = const LapakModel(
        id: 'lapak-01',
        nama: 'Lapak 1 Malioboro',
        lokasi: 'Jl. Malioboro No. 12',
        latitude: -7.792849,
        longitude: 110.365842,
        radiusMeter: 10,
      );
      fakeRepo.mockLapak = testStall;
    });

    test('Initializes state, binds stall, and detects unclocked state', () async {
      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
      );
      await vm.init(currentUser: testUser);

      expect(vm.user?.id, 'user-01');
      expect(vm.stall?.id, 'lapak-01');
      expect(vm.stall?.radiusMeter, 10);
      expect(vm.isClockedInToday, false);
      expect(vm.isClockedOutToday, false);
      expect(vm.recentHistory.isEmpty, true);

      vm.dispose();
    });

    test('Loads pre-existing today attendance and enables clock-out', () async {
      fakeRepo.mockTodayRecord = AbsensiModel(
        id: 'absen-existing',
        tanggal: '2026-10-07',
        jamMasuk: DateTime(2026, 10, 7, 8, 45),
        status: 'hadir',
        lapak: testStall,
      );

      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
      );
      await vm.init(currentUser: testUser);

      expect(vm.isClockedInToday, true);
      expect(vm.isClockedOutToday, false);
      expect(vm.isIzinToday, false);
      expect(vm.todayRecord?.formattedJamMasuk, '08:45');

      vm.dispose();
    });

    test('Correctly identifies isIzinToday when today record is izin', () async {
      fakeRepo.mockTodayRecord = AbsensiModel(
        id: 'absen-izin',
        tanggal: '2026-10-07',
        jamMasuk: null,
        jamPulang: null,
        status: 'izin',
        keterangan: 'Sakit flu',
        lapak: testStall,
      );

      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
      );
      await vm.init(currentUser: testUser);

      expect(vm.isClockedInToday, true);
      expect(vm.isClockedOutToday, false);
      expect(vm.isIzinToday, true);
      expect(vm.todayRecord?.keterangan, 'Sakit flu');
      expect(vm.todayRecord?.formattedJamMasuk, '--:--');

      vm.dispose();
    });

    test('Gracefully handles 409 Conflict when user already clocked in', () async {
      fakeRepo.shouldThrow409OnClockIn = true;

      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
        currentTimeProvider: () => DateTime(2026, 10, 7, 9, 0),
      );
      await vm.init(currentUser: testUser);

      final success = await vm.clockIn();
      expect(success, false);
      expect(vm.errorMessage, 'Anda sudah melakukan presensi masuk hari ini.');

      vm.dispose();
    });

    test('Successfully executes Clock-out and updates status', () async {
      fakeRepo.mockTodayRecord = AbsensiModel(
        id: 'absen-today',
        tanggal: '2026-10-07',
        jamMasuk: DateTime(2026, 10, 7, 8, 50),
        status: 'hadir',
        lapak: testStall,
      );

      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
      );
      await vm.init(currentUser: testUser);

      expect(vm.isClockedOutToday, false);
      final success = await vm.clockOut();

      expect(success, true);
      expect(vm.isClockedOutToday, true);
      expect(vm.todayRecord?.formattedJamPulang, '17:00');

      vm.dispose();
    });

    test('Fetches detail by ID for modal sheet inspection', () async {
      final record = AbsensiModel(
        id: 'absen-inspect',
        tanggal: '2026-10-07',
        jamMasuk: DateTime(2026, 10, 7, 8, 50),
        status: 'hadir',
        keterangan: 'Tepat waktu',
        lapak: testStall,
      );
      fakeRepo.mockHistory = [record];

      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
      );
      await vm.init(currentUser: testUser);

      final detail = await vm.getAttendanceDetail('absen-inspect');
      expect(detail, isNotNull);
      expect(detail?.id, 'absen-inspect');
      expect(detail?.keterangan, 'Tepat waktu');

      vm.dispose();
    });

    test('formattedCurrentTime formats as HH:mm without seconds', () {
      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
      );
      final formatted = vm.formattedCurrentTime;
      expect(RegExp(r'^\d{2}:\d{2}$').hasMatch(formatted), true);
      vm.dispose();
    });

    test('Blocks clock-in when stall coordinates are missing', () async {
      final stallWithoutCoords = const LapakModel(
        id: 'lapak-no-coords',
        nama: 'Lapak Tanpa Koordinat',
        lokasi: 'Jl. Belum Ada GPS',
        latitude: null,
        longitude: null,
      );
      fakeRepo.mockLapak = stallWithoutCoords;

      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
      );
      await vm.init(currentUser: testUser);

      expect(vm.hasStallLocation, false);
      final result = await vm.clockIn();
      expect(result, false);
      expect(vm.errorMessage, contains('Lokasi lapak belum ditentukan'));

      vm.dispose();
    });

    test('Clock-in without photo creates record without calling uploadPhoto', () async {
      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
        currentTimeProvider: () => DateTime(2026, 10, 7, 9, 0),
      );
      await vm.init(currentUser: testUser);

      final success = await vm.clockIn();
      expect(success, true);
      expect(fakeRepo.uploadPhotoCallCount, 0);
      expect(vm.isClockedInToday, true);
      expect(vm.todayRecord?.fotoMasukUrl, isNull);

      vm.dispose();
    });

    test('Clock-in with staged photo triggers uploadPhoto and populates serverPhotoUrl', () async {
      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
      );
      await vm.init(currentUser: testUser);

      // Simulate capturing selfie
      final mockPhoto = File('test_selfie.jpg');
      await fakeRepo.clockIn(
        lapakId: testStall.id,
        latitude: -7.792849,
        longitude: 110.365842,
        photoFile: mockPhoto,
      );

      expect(fakeRepo.uploadPhotoCallCount, 1);
      expect(fakeRepo.mockTodayRecord?.fotoMasukUrl, contains('sample_uploaded.jpg'));

      // ViewModel refresh confirms photo is preserved
      await vm.refreshAttendanceData();
      expect(vm.serverPhotoUrl, contains('sample_uploaded.jpg'));

      vm.dispose();
    });

    test('clearCapturedPhoto resets captured selfie state', () async {
      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
      );
      await vm.init(currentUser: testUser);

      vm.clearCapturedPhoto();
      expect(vm.capturedPhoto, isNull);

      vm.dispose();
    });

    test('submitIzin records absence without requiring geofence radius check', () async {
      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
      );
      await vm.init(currentUser: testUser);

      final result = await vm.submitIzin(keterangan: 'Demam dan flu');
      expect(result, true);
      expect(vm.todayRecord?.status, 'izin');
      expect(vm.todayRecord?.keterangan, 'Demam dan flu');

      vm.dispose();
    });

    test('Correctly resolves shift information for Morning and Afternoon SPG', () async {
      // Pagi user
      final vmPagi = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
      );
      await vmPagi.init(currentUser: testUser.copyWith(shift: 'pagi'));

      expect(vmPagi.userShift, 'pagi');
      expect(vmPagi.userShiftLabel, 'Pagi');
      expect(vmPagi.scheduledClockInTime, '08:00');
      expect(vmPagi.scheduledClockOutTime, '16:00');
      expect(vmPagi.shiftScheduleDisplay, '08:00 - 16:00');
      vmPagi.dispose();

      // Siang user
      final vmSiang = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
      );
      await vmSiang.init(currentUser: testUser.copyWith(shift: 'siang'));

      expect(vmSiang.userShift, 'siang');
      expect(vmSiang.userShiftLabel, 'Siang');
      expect(vmSiang.scheduledClockInTime, '13:00');
      expect(vmSiang.scheduledClockOutTime, '21:00');
      expect(vmSiang.shiftScheduleDisplay, '13:00 - 21:00');
      vmSiang.dispose();
    });

    test('Stall with custom shift hours propagates to ViewModel', () async {
      final customStall = testStall.copyWith(
        shiftPagi: const ['07:00', '15:00'],
        shiftSiang: const ['14:00', '22:00'],
      );
      fakeRepo.mockLapak = customStall;

      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
      );
      await vm.init(currentUser: testUser.copyWith(shift: 'pagi'));

      expect(vm.scheduledClockInTime, '07:00');
      expect(vm.scheduledClockOutTime, '15:00');
      expect(vm.shiftScheduleDisplay, '07:00 - 15:00');
      vm.dispose();
    });

    test('Blocks clock-in when user has no assigned shift', () async {
      const userWithoutShift = UserModel(
        id: 'user-no-shift',
        nama: 'Ahmad SPG',
        username: 'ahmad_spg',
        email: 'ahmad@pot.com',
        role: 'spg',
        lapakId: 'lapak-01',
        noHp: '081234567890',
        status: 'active',
        authProvider: 'local',
      );
      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
      );
      await vm.init(currentUser: userWithoutShift);

      expect(vm.hasShift, false);
      expect(vm.userShiftLabel, 'Belum Ditentukan');
      expect(vm.shiftScheduleDisplay, '--:-- - --:--');
      final result = await vm.clockIn();
      expect(result, false);
      expect(vm.errorMessage, contains('belum memiliki jadwal shift'));
      vm.dispose();
    });

    test('Rejects clock-in before early window opens (< T_start - 180m)', () async {
      // Morning shift starts at 08:00. Window opens at 05:00.
      // Current time is 04:55 -> Too early!
      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
        currentTimeProvider: () => DateTime(2026, 10, 7, 4, 55),
      );
      await vm.init(currentUser: testUser);

      expect(vm.isClockInTooEarly, true);
      expect(vm.isClockInAvailable, false);
      final result = await vm.clockIn();
      expect(result, false);
      expect(vm.errorMessage, contains('belum dibuka'));
      vm.dispose();
    });

    test('Accepts clock-in within 3h early window as hadir', () async {
      // Morning shift starts at 08:00. Window opens at 05:00.
      // Current time is 06:30 -> Inside window!
      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
        currentTimeProvider: () => DateTime(2026, 10, 7, 6, 30),
      );
      await vm.init(currentUser: testUser);

      expect(vm.isClockInTooEarly, false);
      expect(vm.isClockInExpired, false);
      expect(vm.isClockInAvailable, true);
      final result = await vm.clockIn();
      expect(result, true);
      expect(vm.todayRecord?.status, 'hadir');
      vm.dispose();
    });

    test('Correctly resolves shift information for Long Shift SPG', () async {
      final vmLong = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
      );
      await vmLong.init(currentUser: testUser.copyWith(shift: 'long_shift'));

      expect(vmLong.userShift, 'long_shift');
      expect(vmLong.userShiftLabel, 'Long Shift');
      expect(vmLong.scheduledClockInTime, '08:00');
      expect(vmLong.scheduledClockOutTime, '20:00');
      expect(vmLong.shiftScheduleDisplay, '08:00 - 20:00');
      vmLong.dispose();
    });

    test('Detects unclosed previous session, blocks clock-in, and enables clock-out', () async {
      final previousSession = AbsensiModel(
        id: 'absen-yesterday',
        tanggal: '2026-10-06',
        jamMasuk: DateTime(2026, 10, 6, 8, 30),
        jamPulang: null,
        status: 'hadir',
      );
      fakeRepo.mockHistory = [previousSession];

      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
        currentTimeProvider: () => DateTime(2026, 10, 7, 8, 0),
      );
      await vm.init(currentUser: testUser);

      expect(vm.hasUnclosedPreviousSession, true);
      expect(vm.unclosedPreviousSession?.id, 'absen-yesterday');

      // Clock-in must be rejected while an unclosed previous session exists
      final clockInResult = await vm.clockIn();
      expect(clockInResult, false);
      expect(vm.errorMessage, contains('belum melakukan absen pulang'));

      // Clock-out should resolve the previous session
      final clockOutResult = await vm.clockOut();
      expect(clockOutResult, true);
      expect(fakeRepo.clockOutCallCount, 1);
      vm.dispose();
    });
  });

  group('ApiErrorMapper Unit Tests', () {
    test('Translates photo/image format error to clear user message', () {
      final message = ApiErrorMapper.mapStatusToUserMessage(
        statusCode: 400,
        rawMessage: 'Invalid file format for "foto". Allowed types: jpeg, png, webp',
      );
      expect(message, contains('Format file foto tidak valid'));
    });

    test('Translates missing stall location error cleanly', () {
      final message = ApiErrorMapper.mapStatusToUserMessage(
        statusCode: 400,
        rawMessage: 'Lokasi koordinat lapak belum ditentukan oleh Admin.',
      );
      expect(message, contains('Lokasi lapak belum ditentukan'));
    });

    test('Does not mention email for general bad request fallback', () {
      final message = ApiErrorMapper.mapStatusToUserMessage(
        statusCode: 400,
        rawMessage: 'Some validation constraint failed on field abc',
      );
      expect(message, isNot(contains('email')));
      expect(message, 'Some validation constraint failed on field abc');
    });

    test('Falls back to clean default when rawMessage is empty', () {
      final message = ApiErrorMapper.mapStatusToUserMessage(
        statusCode: 400,
        rawMessage: '',
      );
      expect(message, 'Format data yang dimasukkan belum benar.');
    });
  });
}
