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
    this.createdAt,
    this.updatedAt,
  });

  /// True if valid geographic coordinates are assigned to this stall.
  bool get hasCoordinates => latitude != null && longitude != null;

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

    return LapakModel(
      id: json['id'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      lokasi: json['lokasi'] as String? ?? '',
      keterangan: json['keterangan'] as String? ?? '',
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      radiusMeter: parseRadius(json['radius_meter']),
      spgId: json['spg_id'] as String?,
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
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
