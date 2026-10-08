import '../constants/app_constants.dart';
import '../utils/parser_utils.dart';
import 'lapak_model.dart';
import 'pengiriman_model.dart';
import 'user_model.dart';

/// Domain model representing a Receipt (Penerimaan) record
class PenerimaanModel {
  final String id;
  final String pengirimanId;
  final String? uniqueId;
  final String? countersId;
  final String? spgId;
  final DateTime? tanggal;
  final int qtyTerima;
  final String? notaUrl;
  final String catatan;
  final String status;
  final UserModel? spg;
  final PengirimanModel? pengiriman;
  final LapakModel? lapak;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PenerimaanModel({
    required this.id,
    required this.pengirimanId,
    this.uniqueId,
    this.countersId,
    this.spgId,
    this.tanggal,
    required this.qtyTerima,
    this.notaUrl,
    this.catatan = '',
    required this.status,
    this.spg,
    this.pengiriman,
    this.lapak,
    this.createdAt,
    this.updatedAt,
  });

  bool get isSesuai => status.toLowerCase() == AppConstants.receiveSesuai;
  bool get isSelisih => status.toLowerCase() == AppConstants.receiveSelisih;

  /// User-friendly formatted date: e.g. "07 Okt 2026"
  String get formattedTanggal {
    final d = tanggal ?? createdAt;
    if (d == null) return '-';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  /// Day name in Indonesian
  String get dayNameIndo {
    final d = tanggal ?? createdAt;
    if (d == null) return '';
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    return days[d.weekday - 1];
  }

  factory PenerimaanModel.fromJson(Map<String, dynamic> json) {
    return PenerimaanModel(
      id: json['id'] as String? ?? '',
      pengirimanId: json['pengiriman_id'] as String? ?? '',
      uniqueId: json['unique_id'] as String?,
      countersId: json['counters_id'] as String?,
      spgId: json['spg_id'] as String?,
      tanggal: ParserUtils.parseDate(json['tanggal']),
      qtyTerima: ParserUtils.parseInt(json['qty_terima']),
      notaUrl: json['nota_url'] as String?,
      catatan: json['catatan'] as String? ?? '',
      status: json['status'] as String? ?? AppConstants.receiveSesuai,
      spg: json['spg'] is Map<String, dynamic>
          ? UserModel.fromJson(json['spg'] as Map<String, dynamic>)
          : null,
      pengiriman: json['pengiriman'] is Map<String, dynamic>
          ? PengirimanModel.fromJson(json['pengiriman'] as Map<String, dynamic>)
          : null,
      lapak: json['lapak'] is Map<String, dynamic>
          ? LapakModel.fromJson(json['lapak'] as Map<String, dynamic>)
          : null,
      createdAt: ParserUtils.parseDate(json['createdAt']),
      updatedAt: ParserUtils.parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pengiriman_id': pengirimanId,
        'unique_id': uniqueId,
        'counters_id': countersId,
        'spg_id': spgId,
        'tanggal': tanggal?.toIso8601String(),
        'qty_terima': qtyTerima,
        'nota_url': notaUrl,
        'catatan': catatan,
        'status': status,
        'spg': spg?.toJson(),
        'pengiriman': pengiriman?.toJson(),
        'lapak': lapak?.toJson(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
