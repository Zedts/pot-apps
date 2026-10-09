import '../constants/app_constants.dart';
import '../utils/date_formatter.dart';
import '../utils/parser_utils.dart';
import 'user_model.dart';

/// Domain model representing a monthly employee payroll record.
///
/// Mirrors the backend Payroll entity shape returned by `/api/v1/payroll`.
/// The salary total is computed server-side using the formula:
/// `total_gaji = (gaji_pokok + bonus_penjualan + lembur) - (potongan + kasbon)`.
class PayrollModel {
  final String id;
  final String userId;
  final String periode;
  final int hariKerja;
  final int totalPenjualan;
  final int gajiPokok;
  final int bonusPenjualan;
  final int lembur;
  final int potongan;
  final int kasbon;
  final int totalGaji;
  final String status;
  final UserModel? user;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PayrollModel({
    required this.id,
    required this.userId,
    required this.periode,
    required this.hariKerja,
    required this.totalPenjualan,
    required this.gajiPokok,
    required this.bonusPenjualan,
    required this.lembur,
    required this.potongan,
    required this.kasbon,
    required this.totalGaji,
    required this.status,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  /// Returns `true` when payroll status is "published" and visible to employees.
  bool get isPublished => status.trim().toLowerCase() == AppConstants.payrollPublished;

  /// Indonesian-formatted period label, e.g. "September 2026".
  String get formattedPeriode => DateFormatter.formatPeriode(periode);

  /// Parses the [periode] string into the first day of the month.
  ///
  /// Returns a far-past sentinel date when parsing fails so sort comparisons
  /// remain stable instead of throwing.
  DateTime get periodeDateTime {
    return DateFormatter.tryParsePeriode(periode) ?? DateTime(1970, 1, 1);
  }

  /// Human-readable status label.
  String get statusLabel {
    switch (status.trim().toLowerCase()) {
      case AppConstants.payrollDraft:
        return 'Draft';
      case AppConstants.payrollPublished:
        return 'Dipublikasikan';
      default:
        return status.isEmpty ? '-' : status;
    }
  }

  factory PayrollModel.fromJson(Map<String, dynamic> json) {
    final gajiPokok = ParserUtils.parseInt(json['gaji_pokok']);
    final bonusPenjualan = ParserUtils.parseInt(json['bonus_penjualan']);
    final lembur = ParserUtils.parseInt(json['lembur']);
    final potongan = ParserUtils.parseInt(json['potongan']);
    final kasbon = ParserUtils.parseInt(json['kasbon']);
    final serverTotal = ParserUtils.parseInt(json['total_gaji'], -1);

    final int totalGaji;
    if (serverTotal == -1) {
      totalGaji = (gajiPokok + bonusPenjualan + lembur) - (potongan + kasbon);
    } else {
      totalGaji = serverTotal;
    }

    final userJson = json['user'];
    return PayrollModel(
      id: (json['id'] as String?)?.trim() ?? '',
      userId: (json['user_id'] as String?)?.trim() ?? '',
      periode: (json['periode'] as String?)?.trim() ?? '',
      hariKerja: ParserUtils.parseInt(json['hari_kerja']),
      totalPenjualan: ParserUtils.parseInt(json['total_penjualan']),
      gajiPokok: gajiPokok,
      bonusPenjualan: bonusPenjualan,
      lembur: lembur,
      potongan: potongan,
      kasbon: kasbon,
      totalGaji: totalGaji,
      status: (json['status'] as String?)?.trim() ?? AppConstants.payrollDraft,
      user: userJson is Map<String, dynamic> ? UserModel.fromJson(userJson) : null,
      createdAt: ParserUtils.parseLocalDate(json['created_at']),
      updatedAt: ParserUtils.parseLocalDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'periode': periode,
      'hari_kerja': hariKerja,
      'total_penjualan': totalPenjualan,
      'gaji_pokok': gajiPokok,
      'bonus_penjualan': bonusPenjualan,
      'lembur': lembur,
      'potongan': potongan,
      'kasbon': kasbon,
      'total_gaji': totalGaji,
      'status': status,
      'user': user?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
