/// Utility class for safely parsing dynamic values from API responses and JSON payloads.
class ParserUtils {
  ParserUtils._();

  /// Safely parses a dynamic value to [int] with an optional [fallback] (default: 0).
  static int parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) {
      final trimmed = val.trim();
      return int.tryParse(trimmed) ?? (double.tryParse(trimmed)?.toInt() ?? fallback);
    }
    return fallback;
  }

  /// Safely parses a dynamic value to [double] with an optional [fallback] (default: 0.0).
  static double parseDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val is String) {
      return double.tryParse(val.trim()) ?? fallback;
    }
    return fallback;
  }

  /// Safely parses a dynamic value to [DateTime], returning `null` if parsing fails.
  static DateTime? parseDate(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    if (val is String && val.trim().isNotEmpty) {
      return DateTime.tryParse(val.trim());
    }
    return null;
  }

  /// Safely parses a dynamic value to a local [DateTime], returning `null` if parsing fails.
  static DateTime? parseLocalDate(dynamic val) {
    final parsed = parseDate(val);
    return parsed?.toLocal();
  }
}
