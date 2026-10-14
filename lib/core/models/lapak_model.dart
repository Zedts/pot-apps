import '../constants/app_constants.dart';

/// Domain model representing a Lapak (stall/outlet) entity.
class LapakModel {
  final String id;
  final String nama;
  final String lokasi;
  final String keterangan;
  final double? latitude;
  final double? longitude;
  final int radiusMeter;
  final String? spgId;
  final List<String> shiftPagi;
  final List<String> shiftSiang;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LapakModel({
    required this.id,
    required this.nama,
    required this.lokasi,
    this.keterangan = '',
    this.latitude,
    this.longitude,
    this.radiusMeter = 25,
    this.spgId,
    this.shiftPagi = const ['08:00', '16:00'],
    this.shiftSiang = const ['13:00', '21:00'],
    this.createdAt,
    this.updatedAt,
  });

  /// True if valid geographic coordinates are assigned to this stall.
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Resolves the shift hours array [clockIn, clockOut] for the user's assigned shift.
  List<String> getShiftHours(String? shift) {
    if ((shift ?? '').toLowerCase() == AppConstants.shiftSiang) {
      return shiftSiang;
    }
    return shiftPagi;
  }

  /// Formats shift hours into a friendly range string: "08:00 - 16:00"
  String formatShiftHours(String? shift) {
    final hours = getShiftHours(shift);
    if (hours.length >= 2) {
      return '${hours[0]} - ${hours[1]}';
    }
    return '08:00 - 16:00';
  }

  factory LapakModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    int parseRadius(dynamic val) {
      if (val == null) return 25;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 25;
      return 25;
    }

    List<String> parseShift(dynamic val, List<String> fallback) {
      if (val is List) {
        final list = val.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
        if (list.length == 2) return list;
      }
      return fallback;
    }

    return LapakModel(
      id: json['id'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      lokasi: json['lokasi'] as String? ?? '',
      keterangan: json['keterangan'] as String? ?? '',
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      radiusMeter: parseRadius(json['radius_meter']),
      spgId: json['spg_id'] as String?,
      shiftPagi: parseShift(json['shift_pagi'], const ['08:00', '16:00']),
      shiftSiang: parseShift(json['shift_siang'], const ['13:00', '21:00']),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'lokasi': lokasi,
      'keterangan': keterangan,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meter': radiusMeter,
      if (spgId != null) 'spg_id': spgId,
      'shift_pagi': shiftPagi,
      'shift_siang': shiftSiang,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  LapakModel copyWith({
    String? id,
    String? nama,
    String? lokasi,
    String? keterangan,
    double? latitude,
    double? longitude,
    int? radiusMeter,
    String? spgId,
    List<String>? shiftPagi,
    List<String>? shiftSiang,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LapakModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      lokasi: lokasi ?? this.lokasi,
      keterangan: keterangan ?? this.keterangan,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeter: radiusMeter ?? this.radiusMeter,
      spgId: spgId ?? this.spgId,
      shiftPagi: shiftPagi ?? this.shiftPagi,
      shiftSiang: shiftSiang ?? this.shiftSiang,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
