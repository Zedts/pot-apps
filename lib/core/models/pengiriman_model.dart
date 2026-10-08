import '../constants/app_constants.dart';
import 'lapak_model.dart';

/// Single item line in a shipment manifest
class PengirimanItemModel {
  final String id;
  final String pengirimanId;
  final String produkId;
  final String namaProduk;
  final int qty; // dispatched quantity (kirim)
  final double hargaProduk;
  final String jenisSatuan;
  final String? namaKategori;

  const PengirimanItemModel({
    required this.id,
    this.pengirimanId = '',
    required this.produkId,
    required this.namaProduk,
    required this.qty,
    this.hargaProduk = 0.0,
    this.jenisSatuan = 'pcs',
    this.namaKategori,
  });

  factory PengirimanItemModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double parseDouble(dynamic val) {
      if (val is double) return val;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return PengirimanItemModel(
      id: json['id'] as String? ?? '',
      pengirimanId: json['pengiriman_id'] as String? ?? '',
      produkId: json['produk_id'] as String? ?? '',
      namaProduk: json['nama_produk'] as String? ?? '',
      qty: parseInt(json['qty']),
      hargaProduk: parseDouble(json['harga_produk']),
      jenisSatuan: json['jenis_satuan'] as String? ?? 'pcs',
      namaKategori: json['nama_kategori'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pengiriman_id': pengirimanId,
        'produk_id': produkId,
        'nama_produk': namaProduk,
        'qty': qty,
        'harga_produk': hargaProduk,
        'jenis_satuan': jenisSatuan,
        'nama_kategori': namaKategori,
      };
}

/// Item verification tracking when receiving shipment at a stall
class ReceivedItemVerification {
  final PengirimanItemModel item;
  int qtyTerima;

  ReceivedItemVerification({
    required this.item,
    required this.qtyTerima,
  });

  int get qtyKirim => item.qty;
  bool get isSelisih => qtyTerima != qtyKirim;
  int get selisihDiff => qtyTerima - qtyKirim;
  String get namaProduk => item.namaProduk;
  String get jenisSatuan => item.jenisSatuan;
}

/// Domain model representing a Shipment (Pengiriman) record
class PengirimanModel {
  final String id;
  final String uniqueId; // e.g. #PG-20261007-001
  final String? countersId;
  final DateTime? tanggal;
  final String lapakId;
  final String createdBy;
  final String status;
  final int totalItems;
  final int qtyKirim;
  final LapakModel? lapak;
  final Map<String, dynamic>? creator;
  final List<PengirimanItemModel> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PengirimanModel({
    required this.id,
    required this.uniqueId,
    this.countersId,
    this.tanggal,
    required this.lapakId,
    this.createdBy = '',
    required this.status,
    this.totalItems = 0,
    this.qtyKirim = 0,
    this.lapak,
    this.creator,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  bool get isDraft => status.toLowerCase().trim() == AppConstants.deliveryDraft;
  bool get isDikirimViar {
    final s = status.toLowerCase().trim();
    return s == AppConstants.deliveryDikirimViar || s == 'dikirim' || s == 'di jalan';
  }
  bool get isDiterimaSpg {
    final s = status.toLowerCase().trim();
    return s == AppConstants.deliveryDiterimaSPG || s == 'diterima' || s == 'diterima spg';
  }
  bool get isSelesai => status.toLowerCase().trim() == AppConstants.deliverySelesai;

  /// Priority ranking for status display:
  /// 1. "Di Jalan" (dikirim_viar / dikirim)
  /// 2. "Diterima SPG" (diterima_spg / diterima)
  /// 3. "Draft" (draft)
  /// 4. "Selesai" (selesai)
  /// 5. Other / unknown
  int get statusPriority {
    if (isDikirimViar) return 1;
    if (isDiterimaSpg) return 2;
    if (isDraft) return 3;
    if (isSelesai) return 4;
    return 5;
  }

  /// Compares two shipments by status priority first (Di Jalan -> Diterima SPG -> Draft -> Selesai),
  /// then by newest creation timestamp descending.
  static int compareByPriority(PengirimanModel a, PengirimanModel b) {
    final pDiff = a.statusPriority.compareTo(b.statusPriority);
    if (pDiff != 0) return pDiff;
    final dateA = a.createdAt ?? a.tanggal ?? DateTime.fromMillisecondsSinceEpoch(0);
    final dateB = b.createdAt ?? b.tanggal ?? DateTime.fromMillisecondsSinceEpoch(0);
    return dateB.compareTo(dateA);
  }

  PengirimanModel copyWith({
    String? id,
    String? uniqueId,
    String? countersId,
    DateTime? tanggal,
    String? lapakId,
    String? createdBy,
    String? status,
    int? totalItems,
    int? qtyKirim,
    LapakModel? lapak,
    Map<String, dynamic>? creator,
    List<PengirimanItemModel>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PengirimanModel(
      id: id ?? this.id,
      uniqueId: uniqueId ?? this.uniqueId,
      countersId: countersId ?? this.countersId,
      tanggal: tanggal ?? this.tanggal,
      lapakId: lapakId ?? this.lapakId,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      totalItems: totalItems ?? this.totalItems,
      qtyKirim: qtyKirim ?? this.qtyKirim,
      lapak: lapak ?? this.lapak,
      creator: creator ?? this.creator,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// User-friendly formatted time
  String get formattedJam {
    final d = (createdAt ?? tanggal)?.toLocal();
    if (d == null) return '--:-- WIB';
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  /// Formatted date string in Indonesian: e.g. "08 Okt 2026"
  String get formattedTanggal {
    final d = (createdAt ?? tanggal)?.toLocal();
    if (d == null) return '-';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  /// Day name in Indonesian: e.g. "Kamis"
  String get dayNameIndo {
    final d = (createdAt ?? tanggal)?.toLocal();
    if (d == null) return '';
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    return days[d.weekday - 1];
  }

  /// Month name in Indonesian: e.g. "Oktober"
  String get monthNameIndo {
    final d = (createdAt ?? tanggal)?.toLocal();
    if (d == null) return '';
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[d.month - 1];
  }

  /// Formatted creation timestamp with Indonesian day, date, month, year, and time
  /// Example: "Kamis, 08 Oktober 2026 • 14:30 WIB"
  String get formattedCreatedDateTime {
    final d = (createdAt ?? tanggal)?.toLocal();
    if (d == null) return formattedJam;
    final day = dayNameIndo;
    final month = monthNameIndo;
    final dateStr = '${d.day.toString().padLeft(2, '0')} $month ${d.year}';
    final jam = formattedJam;
    if (day.isNotEmpty) {
      return '$day, $dateStr • $jam';
    }
    return '$dateStr • $jam';
  }

  factory PengirimanModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val.toLocal();
      if (val is String && val.isNotEmpty) {
        final parsed = DateTime.tryParse(val);
        return parsed?.toLocal();
      }
      return null;
    }

    LapakModel? parseLapak(dynamic val) {
      if (val is Map<String, dynamic>) {
        return LapakModel.fromJson(val);
      }
      return null;
    }

    List<PengirimanItemModel> parseItems(dynamic val) {
      if (val is List) {
        return val
            .whereType<Map<String, dynamic>>()
            .map((item) => PengirimanItemModel.fromJson(item))
            .toList();
      }
      return [];
    }

    return PengirimanModel(
      id: json['id'] as String? ?? '',
      uniqueId: json['unique_id'] as String? ?? '',
      countersId: json['counters_id'] as String?,
      tanggal: parseDate(json['tanggal']),
      lapakId: json['lapak_id'] as String? ?? '',
      createdBy: json['created_by'] as String? ?? '',
      status: json['status'] as String? ?? AppConstants.deliveryDraft,
      totalItems: parseInt(json['total_items']),
      qtyKirim: parseInt(json['qty_kirim']),
      lapak: parseLapak(json['lapak']),
      creator: json['creator'] is Map<String, dynamic>
          ? json['creator'] as Map<String, dynamic>
          : null,
      items: parseItems(json['items']),
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'unique_id': uniqueId,
        'counters_id': countersId,
        'tanggal': tanggal?.toIso8601String(),
        'lapak_id': lapakId,
        'created_by': createdBy,
        'status': status,
        'total_items': totalItems,
        'qty_kirim': qtyKirim,
        'lapak': lapak?.toJson(),
        'creator': creator,
        'items': items.map((i) => i.toJson()).toList(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
