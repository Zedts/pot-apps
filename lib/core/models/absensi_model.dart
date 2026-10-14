import '../constants/app_constants.dart';
import '../utils/date_formatter.dart';
import '../utils/parser_utils.dart';
import 'lapak_model.dart';
import 'user_model.dart';

/// Geolocation point stamped during clock-in.
class GeolocationPoint {
  final double latitude;
  final double longitude;

  const GeolocationPoint({
    required this.latitude,
    required this.longitude,
  });

  factory GeolocationPoint.fromJson(Map<String, dynamic> json) {
    double parse(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return GeolocationPoint(
      latitude: parse(json['latitude']),
      longitude: parse(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

/// Lapak shift configuration stamped in attendance API responses.
class ShiftLapakModel {
  final String lapakId;
  final List<String> shiftPagi;
  final List<String> shiftSiang;

  const ShiftLapakModel({
    required this.lapakId,
    this.shiftPagi = const [AppConstants.defaultShiftPagiStart, AppConstants.defaultShiftPagiEnd],
    this.shiftSiang = const [AppConstants.defaultShiftSiangStart, AppConstants.defaultShiftSiangEnd],
  });

  factory ShiftLapakModel.fromJson(Map<String, dynamic> json) {
    List<String> parseShift(dynamic v, List<String> fallback) {
      if (v is List) {
        final list = v.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
        if (list.length >= 2) return [list[0], list[1]];
      }
      return fallback;
    }

    return ShiftLapakModel(
      lapakId: json['lapak_id'] as String? ?? '',
      shiftPagi: parseShift(json['shift_pagi'], const [AppConstants.defaultShiftPagiStart, AppConstants.defaultShiftPagiEnd]),
      shiftSiang: parseShift(json['shift_siang'], const [AppConstants.defaultShiftSiangStart, AppConstants.defaultShiftSiangEnd]),
    );
  }

  Map<String, dynamic> toJson() => {
        'lapak_id': lapakId,
        'shift_pagi': shiftPagi,
        'shift_siang': shiftSiang,
      };
}

/// Domain model representing an Attendance (Absensi) record.
class AbsensiModel {
  final String id;
  final String tanggal;
  final DateTime? jamMasuk;
  final DateTime? jamPulang;
  final GeolocationPoint? lokasiMasuk;
  final String? fotoMasukUrl;
  final String status;
  final String keterangan;
  final String? shiftSpg;
  final ShiftLapakModel? shiftLapak;
  final UserModel? user;
  final LapakModel? lapak;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AbsensiModel({
    required this.id,
    required this.tanggal,
    this.jamMasuk,
    this.jamPulang,
    this.lokasiMasuk,
    this.fotoMasukUrl,
    required this.status,
    this.keterangan = '',
    this.shiftSpg,
    this.shiftLapak,
    this.user,
    this.lapak,
    this.createdAt,
    this.updatedAt,
  });

  bool get isClockedOut => jamPulang != null;

  bool get isShiftPagi => shiftSpg == AppConstants.shiftPagi;
  bool get isShiftSiang => shiftSpg == AppConstants.shiftSiang;

  /// Human-readable shift name: "Pagi", "Siang", or "-"
  String get shiftDisplay {
    if (shiftSpg == AppConstants.shiftPagi) return 'Pagi';
    if (shiftSpg == AppConstants.shiftSiang) return 'Siang';
    return '-';
  }

  /// Returns 2-digit formatted clock-in time: "08:55"
  String get formattedJamMasuk {
    if (jamMasuk == null) return '--:--';
    return DateFormatter.formatTime(jamMasuk!);
  }

  /// Returns 2-digit formatted clock-out time: "17:00" or "-"
  String get formattedJamPulang {
    if (jamPulang == null) return '-';
    return DateFormatter.formatTime(jamPulang!);
  }

  /// Formatted date string, e.g. "10 Sep 2026"
  String get formattedTanggal {
    final raw = jamMasuk ?? (DateTime.tryParse(tanggal) ?? DateTime.now());
    return DateFormatter.formatShortDate(raw);
  }

  /// Indonesian day name, e.g. "Kamis"
  String get dayNameIndo {
    final raw = jamMasuk ?? (DateTime.tryParse(tanggal) ?? DateTime.now());
    return DateFormatter.formatDayName(raw);
  }

  /// Human-readable status label in Indonesian
  String get statusDisplay {
    final s = status.toLowerCase();
    if (s == AppConstants.absenHadir) return 'Tepat Waktu';
    if (s == AppConstants.absenTerlambat) return 'Terlambat';
    if (s == AppConstants.absenIzin) return 'Izin';
    return status;
  }

  factory AbsensiModel.fromJson(Map<String, dynamic> json) {
    GeolocationPoint? parseLocation(dynamic v) {
      if (v is Map<String, dynamic>) {
        return GeolocationPoint.fromJson(v);
      }
      return null;
    }

    UserModel? parseUser(dynamic v) {
      if (v is Map<String, dynamic>) {
        return UserModel.fromJson(v);
      }
      return null;
    }

    LapakModel? parseLapak(dynamic v) {
      if (v is Map<String, dynamic>) {
        return LapakModel.fromJson(v);
      }
      return null;
    }

    ShiftLapakModel? parseShiftLapak(dynamic v) {
      if (v is Map<String, dynamic>) {
        return ShiftLapakModel.fromJson(v);
      }
      return null;
    }

    return AbsensiModel(
      id: json['id'] as String? ?? '',
      tanggal: json['tanggal'] as String? ?? '',
      jamMasuk: ParserUtils.parseLocalDate(json['jam_masuk']),
      jamPulang: ParserUtils.parseLocalDate(json['jam_pulang']),
      lokasiMasuk: parseLocation(json['lokasi_masuk']),
      fotoMasukUrl: json['foto_masuk_url'] as String?,
      status: json['status'] as String? ?? AppConstants.absenHadir,
      keterangan: json['keterangan'] as String? ?? '',
      shiftSpg: json['shift_spg'] as String?,
      shiftLapak: parseShiftLapak(json['shift_lapak']),
      user: parseUser(json['user']),
      lapak: parseLapak(json['lapak']),
      createdAt: ParserUtils.parseLocalDate(json['createdAt']),
      updatedAt: ParserUtils.parseLocalDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal': tanggal,
      if (jamMasuk != null) 'jam_masuk': jamMasuk!.toUtc().toIso8601String(),
      if (jamPulang != null) 'jam_pulang': jamPulang!.toUtc().toIso8601String(),
      if (lokasiMasuk != null) 'lokasi_masuk': lokasiMasuk!.toJson(),
      if (fotoMasukUrl != null) 'foto_masuk_url': fotoMasukUrl,
      'status': status,
      'keterangan': keterangan,
      if (shiftSpg != null) 'shift_spg': shiftSpg,
      if (shiftLapak != null) 'shift_lapak': shiftLapak!.toJson(),
      if (user != null) 'user': user!.toJson(),
      if (lapak != null) 'lapak': lapak!.toJson(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  AbsensiModel copyWith({
    String? id,
    String? tanggal,
    DateTime? jamMasuk,
    DateTime? jamPulang,
    GeolocationPoint? lokasiMasuk,
    String? fotoMasukUrl,
    String? status,
    String? keterangan,
    String? shiftSpg,
    ShiftLapakModel? shiftLapak,
    UserModel? user,
    LapakModel? lapak,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AbsensiModel(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      jamMasuk: jamMasuk ?? this.jamMasuk,
      jamPulang: jamPulang ?? this.jamPulang,
      lokasiMasuk: lokasiMasuk ?? this.lokasiMasuk,
      fotoMasukUrl: fotoMasukUrl ?? this.fotoMasukUrl,
      status: status ?? this.status,
      keterangan: keterangan ?? this.keterangan,
      shiftSpg: shiftSpg ?? this.shiftSpg,
      shiftLapak: shiftLapak ?? this.shiftLapak,
      user: user ?? this.user,
      lapak: lapak ?? this.lapak,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
