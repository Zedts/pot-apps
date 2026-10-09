import 'package:flutter/services.dart';

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

  /// Reusable input formatter for text fields
  static TextInputFormatter get inputFormatter => CurrencyInputFormatter();
}

/// Dynamic TextInputFormatter formatting raw digit inputs into IDR thousand separators (e.g., 190000 -> "190.000")
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final amount = int.tryParse(digitsOnly);
    if (amount == null) return oldValue;

    final formatted = CurrencyFormatter.formatRupiah(amount, withPrefix: false);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
