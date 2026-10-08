/// Utility for consistent Indonesian Rupiah (IDR) currency formatting across the app.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats a numeric amount to Indonesian Rupiah standard (e.g. 5000 -> "Rp 5.000").
  /// If [withPrefix] is false, returns only the formatted number (e.g. "5.000").
  static String formatRupiah(num? amount, {bool withPrefix = true}) {
    if (amount == null) {
      return withPrefix ? 'Rp 0' : '0';
    }

    final isNegative = amount < 0;
    final absAmount = amount.abs().round();
    final digits = absAmount.toString();

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }

    final formattedNumber = buffer.toString();
    final sign = isNegative ? '-' : '';

    if (withPrefix) {
      return '$sign' 'Rp $formattedNumber';
    }
    return '$sign$formattedNumber';
  }
}
