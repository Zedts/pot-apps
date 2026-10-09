import '../constants/app_constants.dart';
import '../utils/date_formatter.dart';
import '../utils/parser_utils.dart';
import 'lapak_model.dart';
import 'user_model.dart';

/// Domain model representing a Daily Closing (Closingan) record.
/// Reconciles daily booth inventory balances and financial shift revenue.
class ClosingModel {
  final String id;
  final String spgId;
  final String lapakId;
  final String tanggal; // YYYY-MM-DD
  final int stokSistem;
  final int stokFisik;
  final int totalOmset;
  final int tunaiSistem;
  final int qrisSistem;
  final int transferSistem;
  final int uangTunaiFisik;
  final int selisihStok;
  final int selisihUang;
  final String catatan;
  final String status;
  final String? validatedBy;
  final UserModel? spg;
  final LapakModel? lapak;
  final UserModel? validator;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ClosingModel({
    required this.id,
    required this.spgId,
    required this.lapakId,
    required this.tanggal,
    required this.stokSistem,
    required this.stokFisik,
    required this.totalOmset,
    required this.tunaiSistem,
    required this.qrisSistem,
    required this.transferSistem,
    required this.uangTunaiFisik,
    required this.selisihStok,
    required this.selisihUang,
    this.catatan = '',
    required this.status,
    this.validatedBy,
    this.spg,
    this.lapak,
    this.validator,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPending => status.toLowerCase() == AppConstants.closingPending;
  bool get isTerverifikasi => status.toLowerCase() == AppConstants.closingTerverifikasi;
  bool get isPerluRevisi => status.toLowerCase() == AppConstants.closingRevisi;

  bool get hasStockDiscrepancy => selisihStok != 0;
  bool get hasCashDiscrepancy => selisihUang != 0;
  bool get hasAnyDiscrepancy => hasStockDiscrepancy || hasCashDiscrepancy;

  /// Human-readable Indonesian label for closing status
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'terverifikasi':
        return 'Terverifikasi';
      case 'perlu_revisi':
        return 'Perlu Revisi';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  /// Formatted short date (e.g. "11 Sep 2026")
  String get formattedTanggal {
    final parsed = DateTime.tryParse(tanggal);
    final d = parsed ?? createdAt;
    if (d == null) return tanggal.isNotEmpty ? tanggal : '-';
    return DateFormatter.formatShortDate(d);
  }

  /// Day name in Indonesian
  String get dayNameIndo {
    final parsed = DateTime.tryParse(tanggal);
    final d = parsed ?? createdAt;
    if (d == null) return '';
    return DateFormatter.formatDayName(d);
  }

  /// Formatted full date (e.g. "Jumat, 11 September 2026")
  String get formattedTanggalFull {
    final parsed = DateTime.tryParse(tanggal);
    final d = parsed ?? createdAt;
    if (d == null) return tanggal.isNotEmpty ? tanggal : '-';
    return DateFormatter.formatFullDate(d);
  }

  /// Formatted full date with time (e.g. "Jumat, 11 September 2026, 19:45")
  String get formattedTanggalFullWithTime {
    final parsed = DateTime.tryParse(tanggal);
    final d = parsed ?? createdAt;
    if (d == null) return tanggal.isNotEmpty ? tanggal : '-';
    final dateStr = DateFormatter.formatFullDate(d);
    final timeSource = (parsed != null && (parsed.hour != 0 || parsed.minute != 0))
        ? parsed
        : (createdAt ?? updatedAt);
    if (timeSource != null) {
      final timeStr = DateFormatter.formatTime(timeSource);
      return '$dateStr, $timeStr';
    }
    return dateStr;
  }

  factory ClosingModel.fromJson(Map<String, dynamic> json) {
    LapakModel? lapakModel;
    if (json['lapak'] is Map) {
      lapakModel = LapakModel.fromJson(Map<String, dynamic>.from(json['lapak']));
    }

    UserModel? spgModel;
    if (json['spg'] is Map) {
      spgModel = UserModel.fromJson(Map<String, dynamic>.from(json['spg']));
    }

    UserModel? validatorModel;
    if (json['validator'] is Map) {
      validatorModel = UserModel.fromJson(Map<String, dynamic>.from(json['validator']));
    }

    final sSistem = ParserUtils.parseInt(json['stok_sistem']);
    final sFisik = ParserUtils.parseInt(json['stok_fisik']);
    final tOmset = ParserUtils.parseInt(json['total_omset']);
    final tSistem = ParserUtils.parseInt(json['tunai_sistem']);
    final qSistem = ParserUtils.parseInt(json['qris_sistem']);
    final trSistem = ParserUtils.parseInt(json['transfer_sistem']);
    final uFisik = ParserUtils.parseInt(json['uang_tunai_fisik']);

    final selStokRaw = json['selisih_stok'];
    final selStok = selStokRaw != null ? ParserUtils.parseInt(selStokRaw) : (sFisik - sSistem);

    final selUangRaw = json['selisih_uang'];
    final selUang = selUangRaw != null ? ParserUtils.parseInt(selUangRaw) : (uFisik - tOmset);

    return ClosingModel(
      id: json['id']?.toString() ?? '',
      spgId: json['spg_id']?.toString() ?? (spgModel?.id ?? ''),
      lapakId: json['lapak_id']?.toString() ?? (lapakModel?.id ?? ''),
      tanggal: json['tanggal']?.toString() ?? '',
      stokSistem: sSistem,
      stokFisik: sFisik,
      totalOmset: tOmset,
      tunaiSistem: tSistem,
      qrisSistem: qSistem,
      transferSistem: trSistem,
      uangTunaiFisik: uFisik,
      selisihStok: selStok,
      selisihUang: selUang,
      catatan: json['catatan']?.toString() ?? '',
      status: json['status']?.toString() ?? AppConstants.closingPending,
      validatedBy: json['validated_by']?.toString(),
      spg: spgModel,
      lapak: lapakModel,
      validator: validatorModel,
      createdAt: ParserUtils.parseLocalDate(json['createdAt']),
      updatedAt: ParserUtils.parseLocalDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'spg_id': spgId,
      'lapak_id': lapakId,
      'tanggal': tanggal,
      'stok_sistem': stokSistem,
      'stok_fisik': stokFisik,
      'total_omset': totalOmset,
      'tunai_sistem': tunaiSistem,
      'qris_sistem': qrisSistem,
      'transfer_sistem': transferSistem,
      'uang_tunai_fisik': uangTunaiFisik,
      'selisih_stok': selisihStok,
      'selisih_uang': selisihUang,
      'catatan': catatan,
      'status': status,
      if (validatedBy != null) 'validated_by': validatedBy,
    };
  }
}
