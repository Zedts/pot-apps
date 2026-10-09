import '../utils/date_formatter.dart';
import '../utils/parser_utils.dart';
import 'payroll_model.dart';

/// Domain model representing an uploaded salary-slip document (PDF).
///
/// Each [SlipGajiModel] is attached to exactly one [PayrollModel] via
/// [payrollId]. The server uploads the document to Cloudinary and returns
/// [fileUrl] for viewing/downloading.
class SlipGajiModel {
  final String id;
  final String payrollId;
  final String? fileUrl;
  final String tanggal;
  final PayrollModel? payroll;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SlipGajiModel({
    required this.id,
    required this.payrollId,
    this.fileUrl,
    required this.tanggal,
    this.payroll,
    this.createdAt,
    this.updatedAt,
  });

  /// Returns `true` when a PDF document has been uploaded and is accessible.
  bool get hasPdf => fileUrl != null && fileUrl!.trim().isNotEmpty;

  /// Short Indonesian-formatted date of the slip issue date.
  String get formattedTanggal {
    final parsed = DateFormatter.tryParsePeriode(tanggal);
    if (parsed != null) return DateFormatter.formatShortDate(parsed);
    final rawDate = DateTime.tryParse(tanggal.trim());
    if (rawDate != null) return DateFormatter.formatShortDate(rawDate);
    return tanggal.trim().isEmpty ? '-' : tanggal.trim();
  }

  factory SlipGajiModel.fromJson(Map<String, dynamic> json) {
    final payrollJson = json['payroll'];
    return SlipGajiModel(
      id: (json['id'] as String?)?.trim() ?? '',
      payrollId: (json['payroll_id'] as String?)?.trim() ?? '',
      fileUrl: (json['file_url'] as String?)?.trim(),
      tanggal: (json['tanggal'] as String?)?.trim() ?? '',
      payroll: payrollJson is Map<String, dynamic> ? PayrollModel.fromJson(payrollJson) : null,
      createdAt: ParserUtils.parseLocalDate(json['created_at']),
      updatedAt: ParserUtils.parseLocalDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payroll_id': payrollId,
      'file_url': fileUrl,
      'tanggal': tanggal,
      'payroll': payroll?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
