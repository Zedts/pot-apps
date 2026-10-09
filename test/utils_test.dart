import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pot_apps/core/network/api_error_mapper.dart';
import 'package:pot_apps/core/utils/currency_formatter.dart';
import 'package:pot_apps/core/utils/date_formatter.dart';
import 'package:pot_apps/core/utils/parser_utils.dart';

void main() {
  group('DateFormatter Unit Tests', () {
    test('formatFullDate formats datetime into Indonesian text correctly', () {
      final date = DateTime(2026, 10, 8); // Thursday
      final formatted = DateFormatter.formatFullDate(date);
      expect(formatted, 'Kamis, 8 Oktober 2026');
    });

    test('formatShortDate formats datetime into compact Indonesian text', () {
      final date = DateTime(2026, 10, 8);
      final formatted = DateFormatter.formatShortDate(date);
      expect(formatted, '8 Okt 2026');
    });

    test('formatCurrentDate returns non-empty formatted date', () {
      final formatted = DateFormatter.formatCurrentDate();
      expect(formatted, isNotEmpty);
      expect(formatted, contains('2026'));
    });
  });

  group('ParserUtils Unit Tests', () {
    test('parseInt safely parses int, num, string, and fallbacks', () {
      expect(ParserUtils.parseInt(42), 42);
      expect(ParserUtils.parseInt(42.8), 42);
      expect(ParserUtils.parseInt('123'), 123);
      expect(ParserUtils.parseInt('  456  '), 456);
      expect(ParserUtils.parseInt(null, 10), 10);
      expect(ParserUtils.parseInt('invalid', 99), 99);
      expect(ParserUtils.parseInt({}, 5), 5);
    });

    test('parseDouble safely parses double, int, string, and fallbacks', () {
      expect(ParserUtils.parseDouble(42.5), 42.5);
      expect(ParserUtils.parseDouble(10), 10.0);
      expect(ParserUtils.parseDouble('123.45'), 123.45);
      expect(ParserUtils.parseDouble(null, 1.5), 1.5);
      expect(ParserUtils.parseDouble('not_a_num', 2.0), 2.0);
    });

    test('parseDate parses ISO date strings correctly', () {
      expect(ParserUtils.parseDate(null), isNull);
      expect(ParserUtils.parseDate(''), isNull);
      final parsed = ParserUtils.parseDate('2026-10-08T08:00:00Z');
      expect(parsed, isNotNull);
      expect(parsed!.year, 2026);
      expect(parsed.month, 10);
      expect(parsed.day, 8);
    });

    test('parseLocalDate returns local timezone DateTime', () {
      final utc = DateTime.utc(2026, 10, 8, 12, 0);
      final local = ParserUtils.parseLocalDate(utc);
      expect(local, isNotNull);
      expect(local!.isUtc, isFalse);
    });
  });

  group('ApiErrorMapper 404 Contextual Tests', () {
    test('maps lapak 404 cleanly', () {
      final msg = ApiErrorMapper.mapStatusToUserMessage(
        statusCode: 404,
        rawMessage: 'Lapak not found',
      );
      expect(msg, 'Data lapak tidak ditemukan.');
    });

    test('maps pengiriman 404 cleanly', () {
      final msg = ApiErrorMapper.mapStatusToUserMessage(
        statusCode: 404,
        rawMessage: 'Shipment with ID 123 not found',
      );
      expect(msg, 'Data pengiriman barang tidak ditemukan.');
    });

    test('maps produk 404 cleanly', () {
      final msg = ApiErrorMapper.mapStatusToUserMessage(
        statusCode: 404,
        rawMessage: 'Produk tidak ditemukan',
      );
      expect(msg, 'Data produk tidak ditemukan.');
    });

    test('maps stok 404 cleanly', () {
      final msg = ApiErrorMapper.mapStatusToUserMessage(
        statusCode: 404,
        rawMessage: 'Stock document not found',
      );
      expect(msg, 'Data stok produk tidak ditemukan.');
    });

    test('maps penjualan 404 cleanly', () {
      final msg = ApiErrorMapper.mapStatusToUserMessage(
        statusCode: 404,
        rawMessage: 'Sales transaction not found',
      );
      expect(msg, 'Data transaksi penjualan tidak ditemukan.');
    });

    test('maps user 404 cleanly', () {
      final msg = ApiErrorMapper.mapStatusToUserMessage(
        statusCode: 404,
        rawMessage: 'User account not found',
      );
      expect(msg, 'Akun pengguna tidak ditemukan di sistem.');
    });

    test('falls back cleanly for generic 404 without rawMessage', () {
      final msg = ApiErrorMapper.mapStatusToUserMessage(
        statusCode: 404,
        rawMessage: '',
      );
      expect(msg, 'Data yang dicari tidak ditemukan di sistem.');
    });
  });

  group('CurrencyFormatter and CurrencyInputFormatter Unit Tests', () {
    test('formats numbers into Indonesian Rupiah text with and without prefix', () {
      expect(CurrencyFormatter.formatRupiah(190000), 'Rp 190.000');
      expect(CurrencyFormatter.formatRupiah(190000, withPrefix: false), '190.000');
      expect(CurrencyFormatter.formatRupiah(0), 'Rp 0');
      expect(CurrencyFormatter.formatRupiah(null), 'Rp 0');
    });

    test('CurrencyInputFormatter formats user typing with thousand separators', () {
      final formatter = CurrencyFormatter.inputFormatter;

      // Type 190000
      const oldVal = TextEditingValue.empty;
      const newVal = TextEditingValue(text: '190000', selection: TextSelection.collapsed(offset: 6));
      final updated = formatter.formatEditUpdate(oldVal, newVal);

      expect(updated.text, '190.000');
      expect(updated.selection.baseOffset, 7);

      // Backspace from 190.000 to 190.00
      const editedVal = TextEditingValue(text: '190.00', selection: TextSelection.collapsed(offset: 6));
      final backspaced = formatter.formatEditUpdate(newVal, editedVal);
      expect(backspaced.text, '19.000');

      // Clear all
      const clearedVal = TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
      final cleared = formatter.formatEditUpdate(newVal, clearedVal);
      expect(cleared.text, '');
    });
  });
}
