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
      expect(vm.todayRecord?.formattedJamMasuk, '08:45');

      vm.dispose();
    });

    test('Gracefully handles 409 Conflict when user already clocked in', () async {
      fakeRepo.shouldThrow409OnClockIn = true;

      final vm = AttendanceViewModel(
        repository: fakeRepo,
        locationService: fakeLocation,
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
