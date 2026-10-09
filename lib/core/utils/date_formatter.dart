/// Utility class for Indonesian date and time formatting.
class DateFormatter {
  DateFormatter._();

  static const List<String> indonesianDays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> indonesianMonths = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Formats a [DateTime] into Indonesian format: e.g. "Kamis, 8 Oktober 2026"
  static String formatFullDate(DateTime date) {
    final local = date.toLocal();
    final dayName = indonesianDays[local.weekday - 1];
    final monthName = indonesianMonths[local.month - 1];
    return '$dayName, ${local.day} $monthName ${local.year}';
  }

  /// Formats current date/time into Indonesian format: e.g. "Kamis, 8 Oktober 2026"
  static String formatCurrentDate() {
    return formatFullDate(DateTime.now());
  }

  /// Formats a [DateTime] into Indonesian compact date: e.g. "8 Okt 2026"
  static String formatShortDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day} ${shortMonths[local.month - 1]} ${local.year}';
  }

  /// Formats a [DateTime] into Indonesian date and time: e.g. "08 Okt 2026, 14:30"
  static String formatDateTime(DateTime date) {
    final local = date.toLocal();
    final dayStr = local.day.toString().padLeft(2, '0');
    final monthStr = shortMonths[local.month - 1];
    final timePart = formatTime(local);
    return '$dayStr $monthStr ${local.year}, $timePart';
  }

  /// Formats a [DateTime] into 24-hour time: e.g. "14:30"
  static String formatTime(DateTime date) {
    final local = date.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Returns Indonesian day name for a [DateTime]: e.g. "Kamis"
  static String formatDayName(DateTime date) {
    final local = date.toLocal();
    return indonesianDays[local.weekday - 1];
  }

  /// Formats a [DateTime] into standard ISO date string: e.g. "2026-10-09"
  static String formatDateIso(DateTime date) {
    final local = date.toLocal();
    final y = local.year.toString();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Returns `true` if [a] and [b] represent the same calendar day in local time.
  static bool isSameDay(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year && localA.month == localB.month && localA.day == localB.day;
  }

  /// Formats a period string in "YYYY-MM" format to Indonesian long month format.
  ///
  /// Example: `"2026-09"` → `"September 2026"`.
  /// Falls back to the raw input string when it does not match the expected format.
  static String formatPeriode(String periode) {
    final trimmed = periode.trim();
    final parts = trimmed.split('-');
    if (parts.length != 2) return trimmed;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null) return trimmed;
    if (month < 1 || month > 12) return trimmed;
    return '${indonesianMonths[month - 1]} $year';
  }

  /// Parses a "YYYY-MM" period string into a [DateTime] at the first day of the month.
  ///
  /// Returns `null` if the string cannot be parsed.
  static DateTime? tryParsePeriode(String periode) {
    final trimmed = periode.trim();
    final parts = trimmed.split('-');
    if (parts.length != 2) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null) return null;
    if (month < 1 || month > 12) return null;
    return DateTime(year, month, 1);
  }
}
