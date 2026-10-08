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

  /// Formats a [DateTime] into Indonesian format: e.g. "Kamis, 8 Oktober 2026"
  static String formatFullDate(DateTime date) {
    final dayName = indonesianDays[date.weekday - 1];
    final monthName = indonesianMonths[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  /// Formats current date/time into Indonesian format: e.g. "Kamis, 8 Oktober 2026"
  static String formatCurrentDate() {
    return formatFullDate(DateTime.now());
  }

  /// Formats a [DateTime] into Indonesian compact date: e.g. "8 Okt 2026"
  static String formatShortDate(DateTime date) {
    const shortMonths = [
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
    return '${date.day} ${shortMonths[date.month - 1]} ${date.year}';
  }
}
