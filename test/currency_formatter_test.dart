import 'package:flutter_test/flutter_test.dart';
import 'package:pot_apps/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('formats standard positive numbers to Indonesian Rupiah', () {
      expect(CurrencyFormatter.formatRupiah(5000), 'Rp 5.000');
      expect(CurrencyFormatter.formatRupiah(15000), 'Rp 15.000');
      expect(CurrencyFormatter.formatRupiah(150000), 'Rp 150.000');
      expect(CurrencyFormatter.formatRupiah(1250000), 'Rp 1.250.000');
    });

    test('formats zero and null safely', () {
      expect(CurrencyFormatter.formatRupiah(0), 'Rp 0');
      expect(CurrencyFormatter.formatRupiah(null), 'Rp 0');
    });

    test('supports withPrefix: false', () {
      expect(CurrencyFormatter.formatRupiah(5000, withPrefix: false), '5.000');
      expect(CurrencyFormatter.formatRupiah(150000, withPrefix: false), '150.000');
      expect(CurrencyFormatter.formatRupiah(0, withPrefix: false), '0');
      expect(CurrencyFormatter.formatRupiah(null, withPrefix: false), '0');
    });

    test('formats negative numbers correctly', () {
      expect(CurrencyFormatter.formatRupiah(-5000), '-Rp 5.000');
      expect(CurrencyFormatter.formatRupiah(-150000, withPrefix: false), '-150.000');
    });
  });
}
