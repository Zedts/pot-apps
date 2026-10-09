import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pot_apps/core/models/closing_model.dart';
import 'package:pot_apps/core/models/lapak_model.dart';
import 'package:pot_apps/core/models/penerimaan_model.dart';
import 'package:pot_apps/core/models/penjualan_model.dart';
import 'package:pot_apps/core/models/stok_lapak_model.dart';
import 'package:pot_apps/core/models/user_model.dart';
import 'package:pot_apps/core/utils/date_formatter.dart';
import 'package:pot_apps/screens/closingan/repositories/closingan_repository.dart';
import 'package:pot_apps/screens/closingan/viewmodels/closing_history_view_model.dart';
import 'package:pot_apps/screens/closingan/viewmodels/closingan_view_model.dart';
import 'package:pot_apps/widgets/attendance/attendance_status_badge.dart';
import 'package:pot_apps/widgets/closingan/closing_inventory_summary_card.dart';
import 'package:pot_apps/widgets/closingan/closing_sales_summary_card.dart';
import 'package:pot_apps/widgets/common/dynamic_field_hint.dart';
import 'package:pot_apps/widgets/common/lapak_info_card.dart';

class MockClosinganRepository implements ClosinganRepository {
  List<StokLapakModel> mockStock = [];
  List<PenjualanModel> mockSales = [];
  List<PenerimaanModel> mockReceipts = [];
  List<ClosingModel> mockHistory = [];
  ClosingModel? mockTodayClosing;
  LapakModel? mockLapak;

  @override
  Future<List<StokLapakModel>> getStokLapak(String lapakId) async => mockStock;

  @override
  Future<List<PenjualanModel>> getSalesHistory({
    required String lapakId,
    String? tanggal,
    String? spgId,
  }) async => mockSales;

  @override
  Future<List<PenerimaanModel>> getReceiptHistory({
    required String lapakId,
    String? tanggal,
  }) async => mockReceipts;

  @override
  Future<LapakModel?> getLapak(String lapakId) async => mockLapak;

  @override
  Future<ClosingModel> createClosing(Map<String, dynamic> payload) async {
    final entity = ClosingModel.fromJson({
      'id': 'cls_new_1',
      ...payload,
    });
    mockHistory.insert(0, entity);
    mockTodayClosing = entity;
    return entity;
  }

  @override
  Future<List<ClosingModel>> getClosingHistory({
    required String lapakId,
    String? spgId,
    String? tanggal,
    String? status,
  }) async {
    if (status != null && status.isNotEmpty) {
      return mockHistory.where((c) => c.status == status).toList();
    }
    return mockHistory;
  }

  @override
  Future<ClosingModel?> getTodayClosing({
    required String lapakId,
    required String tanggal,
  }) async => mockTodayClosing;
}

void main() {
  group('ClosingModel Tests', () {
    test('Correctly parses from JSON and formats discrepancies and dates', () {
      final json = {
        'id': 'closing_123',
        'spg_id': 'spg_1',
        'lapak_id': 'lapak_2',
        'tanggal': '2026-09-11',
        'stok_sistem': 87,
        'stok_fisik': 80,
        'total_omset': 1245000,
        'tunai_sistem': 820000,
        'qris_sistem': 425000,
        'transfer_sistem': 0,
        'uang_tunai_fisik': 772000,
        'selisih_stok': -7,
        'selisih_uang': -48000,
        'catatan': 'Ada kue rusak',
        'status': 'pending',
      };

      final model = ClosingModel.fromJson(json);

      expect(model.id, 'closing_123');
      expect(model.stokSistem, 87);
      expect(model.stokFisik, 80);
      expect(model.selisihStok, -7);
      expect(model.selisihUang, -48000);
      expect(model.hasStockDiscrepancy, isTrue);
      expect(model.hasCashDiscrepancy, isTrue);
      expect(model.hasAnyDiscrepancy, isTrue);
      expect(model.isPending, isTrue);
      expect(model.statusLabel, 'Pending');
      expect(model.formattedTanggal, '11 Sep 2026');
      expect(model.dayNameIndo, 'Jumat');
    });

    test('toJson produces expected structure', () {
      const model = ClosingModel(
        id: 'c1',
        spgId: 's1',
        lapakId: 'l1',
        tanggal: '2026-10-09',
        stokSistem: 100,
        stokFisik: 100,
        totalOmset: 500000,
        tunaiSistem: 300000,
        qrisSistem: 200000,
        transferSistem: 0,
        uangTunaiFisik: 300000,
        selisihStok: 0,
        selisihUang: 0,
        status: 'pending',
      );

      final json = model.toJson();
      expect(json['id'], 'c1');
      expect(json['stok_sistem'], 100);
      expect(json['selisih_stok'], 0);
      expect(json['selisih_uang'], 0);
      expect(json['total_omset'], 500000);
    });

    test('formattedTanggalFullWithTime formats date with time correctly', () {
      final modelWithTime = ClosingModel.fromJson({
        'id': 'c1',
        'spg_id': 's1',
        'lapak_id': 'l1',
        'tanggal': '2026-10-09',
        'createdAt': '2026-10-09T19:45:00.000Z',
        'stok_sistem': 10,
        'stok_fisik': 10,
        'total_omset': 100000,
        'status': 'terverifikasi',
      });

      expect(modelWithTime.formattedTanggalFullWithTime, contains('Jumat, 9 Oktober 2026'));
      expect(modelWithTime.formattedTanggalFullWithTime, contains(':'));
    });
  });

  group('ClosinganViewModel Tests', () {
    late MockClosinganRepository mockRepo;
    late ClosinganViewModel viewModel;

    setUp(() {
      mockRepo = MockClosinganRepository();
      mockRepo.mockStock = [
        const StokLapakModel(
          id: 's1',
          lapakId: 'lapak_1',
          produkId: 'p1',
          stokAwal: 200,
          stokMasuk: 50,
          stokTerjual: 150,
          stokAkhir: 100,
        ),
        const StokLapakModel(
          id: 's2',
          lapakId: 'lapak_1',
          produkId: 'p2',
          stokAwal: 100,
          stokMasuk: 0,
          stokTerjual: 50,
          stokAkhir: 50,
        ),
      ];

      final today = DateTime.now();
      mockRepo.mockReceipts = [
        PenerimaanModel(
          id: 'rc1',
          pengirimanId: 'pg1',
          tanggal: today,
          qtyTerima: 20,
          status: 'sesuai',
        ),
        // Previous day receipt - must NOT be included in today's closing
        PenerimaanModel(
          id: 'rc_old',
          pengirimanId: 'pg2',
          tanggal: today.subtract(const Duration(days: 2)),
          qtyTerima: 80,
          status: 'sesuai',
        ),
      ];

      mockRepo.mockSales = [
        PenjualanModel(
          id: 'pj1',
          tanggal: today,
          totalHarga: 250000,
          metodePembayaran: 'tunai',
          items: const [
            PenjualanItemModel(id: 'it1', produkId: 'p1', namaProduk: 'Produk 1', hargaSatuan: 25000, qty: 10, subtotal: 250000),
          ],
        ),
        PenjualanModel(
          id: 'pj2',
          tanggal: today,
          totalHarga: 150000,
          metodePembayaran: 'qris',
          items: const [
            PenjualanItemModel(id: 'it2', produkId: 'p2', namaProduk: 'Produk 2', hargaSatuan: 15000, qty: 10, subtotal: 150000),
          ],
        ),
        PenjualanModel(
          id: 'pj3',
          tanggal: today,
          totalHarga: 50000,
          metodePembayaran: 'transfer',
          items: const [
            PenjualanItemModel(id: 'it3', produkId: 'p1', namaProduk: 'Produk 1', hargaSatuan: 25000, qty: 2, subtotal: 50000),
          ],
        ),
        // Previous day transaction - must NOT be included in today's closing
        PenjualanModel(
          id: 'pj_old',
          tanggal: today.subtract(const Duration(days: 2)),
          totalHarga: 999999,
          metodePembayaran: 'tunai',
          items: const [
            PenjualanItemModel(id: 'it4', produkId: 'p1', namaProduk: 'Produk 1', hargaSatuan: 25000, qty: 50, subtotal: 999999),
          ],
        ),
      ];

      mockRepo.mockLapak = const LapakModel(
        id: 'lapak_1',
        nama: 'Lapak 1 Alun-Alun',
        lokasi: 'Yogyakarta',
        latitude: -7.79,
        longitude: 110.36,
      );

      const user = UserModel(
        id: 'u1',
        nama: 'SPG 1',
        username: 'spg1',
        email: 'spg@test.com',
        role: 'spg',
        lapakId: 'lapak_1',
        noHp: '08123456789',
        status: 'active',
        authProvider: 'local',
      );

      viewModel = ClosinganViewModel(
        currentUser: user,
        repository: mockRepo,
      );
    });

    test('Aggregates single-day shift inventory balance accurately', () async {
      await viewModel.initialize();

      expect(viewModel.stokSistem, 150);
      expect(viewModel.totalBarangMasukHariIni, 20);
      expect(viewModel.totalStokTerjualHariIni, 22);
      expect(viewModel.totalStokAwalHariIni, 152);

      // Verify invariant: Stok Awal + Barang Masuk - Terjual == Stok Sistem
      expect(
        viewModel.totalStokAwalHariIni +
            viewModel.totalBarangMasukHariIni -
            viewModel.totalStokTerjualHariIni,
        viewModel.stokSistem,
      );
    });

    test('Correctly handles transaction made at 00:43 after midnight with UTC parse', () async {
      final now = DateTime.now();
      final midnightLocal = DateTime(now.year, now.month, now.day, 0, 43);
      final midnightIso = midnightLocal.toUtc().toIso8601String();
      final parsedSale = PenjualanModel.fromJson({
        'id': 'pj_midnight',
        'tanggal': midnightIso,
        'total_harga': 100000,
        'metode_pembayaran': 'tunai',
        'items': [
          {'produk_id': 'p1', 'nama_produk': 'Produk 1', 'harga_satuan': 50000, 'qty': 2, 'subtotal': 100000}
        ],
      });

      expect(DateFormatter.isSameDay(parsedSale.tanggal!, now), isTrue);
      expect(parsedSale.formattedDateTime, contains('00:43'));
    });

    test('Strictly aggregates sales for today only and ignores previous days', () async {
      await viewModel.initialize();

      expect(viewModel.todaySales.length, 3);
      expect(viewModel.tunaiSistem, 250000);
      expect(viewModel.qrisSistem, 150000);
      expect(viewModel.transferSistem, 50000);
      expect(viewModel.totalOmset, 450000);
    });

    test('Computes live discrepancies and dynamic hints correctly', () async {
      await viewModel.initialize();

      // Balanced initially (defaults to system)
      expect(viewModel.selisihStok, 0);
      expect(viewModel.selisihUang, 0);
      expect(viewModel.hasAnyDiscrepancy, isFalse);
      expect(viewModel.dynamicHintText, contains('sesuai'));

      // User enters custom physical stock (deficit of 5 pcs)
      viewModel.setStokFisik(145);
      expect(viewModel.selisihStok, -5);
      expect(viewModel.hasStockDiscrepancy, isTrue);
      expect(viewModel.hasAnyDiscrepancy, isTrue);
      expect(viewModel.dynamicHintText, contains('Terdapat selisih'));
      expect(viewModel.suggestedDiscrepancyNote, contains('selisih stok -5 pcs'));

      // User enters cash shortage of Rp 20.000 against totalOmset (450.000)
      viewModel.setUangTunaiFisik(430000);
      expect(viewModel.selisihUang, -20000);
      expect(viewModel.hasCashDiscrepancy, isTrue);
      expect(viewModel.suggestedDiscrepancyNote, contains('selisih kasir -Rp 20.000'));
    });
  });

  group('ClosingHistoryViewModel Tests', () {
    test('Calculates summary counts and filters records properly', () async {
      final mockRepo = MockClosinganRepository();
      mockRepo.mockHistory = [
        const ClosingModel(
          id: 'c1',
          spgId: 's1',
          lapakId: 'l1',
          tanggal: '2026-10-09',
          stokSistem: 100,
          stokFisik: 100,
          totalOmset: 500000,
          tunaiSistem: 300000,
          qrisSistem: 200000,
          transferSistem: 0,
          uangTunaiFisik: 300000,
          selisihStok: 0,
          selisihUang: 0,
          status: 'terverifikasi',
        ),
        const ClosingModel(
          id: 'c2',
          spgId: 's1',
          lapakId: 'l1',
          tanggal: '2026-10-08',
          stokSistem: 100,
          stokFisik: 95,
          totalOmset: 400000,
          tunaiSistem: 300000,
          qrisSistem: 100000,
          transferSistem: 0,
          uangTunaiFisik: 280000,
          selisihStok: -5,
          selisihUang: -20000,
          status: 'pending',
        ),
      ];

      const user = UserModel(
        id: 'u1',
        nama: 'SPG 1',
        username: 'spg1',
        email: 'spg@test.com',
        role: 'spg',
        lapakId: 'l1',
        noHp: '08123456789',
        status: 'active',
        authProvider: 'local',
      );

      final vm = ClosingHistoryViewModel(
        currentUser: user,
        repository: mockRepo,
      );
      await vm.initialize();

      expect(vm.totalCount, 2);
      expect(vm.balancedCount, 1);
      expect(vm.discrepantCount, 1);
      expect(vm.terverifikasiCount, 1);
      expect(vm.pendingCount, 1);

      // Filtering
      vm.setFilter('terverifikasi');
      expect(vm.filteredHistory.length, 1);
      expect(vm.filteredHistory.first.id, 'c1');

      vm.setFilter('pending');
      expect(vm.filteredHistory.length, 1);
      expect(vm.filteredHistory.first.id, 'c2');
    });
  });

  group('Reusable Widgets Widget Tests', () {
    testWidgets('LapakInfoCard renders stall name and verified badge', (tester) async {
      const stall = LapakModel(
        id: 'l1',
        nama: 'Lapak 2 Malioboro',
        lokasi: 'Malioboro',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LapakInfoCard(stall: stall),
          ),
        ),
      );

      expect(find.text('Lapak 2 Malioboro'), findsOneWidget);
      expect(find.text('Lokasi Terverifikasi (Lapak Aktif)'), findsOneWidget);
    });

    testWidgets('DynamicFieldHint renders warning icon and fires onTap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFieldHint(
              hintText: 'Periksa kembali selisih stok',
              isWarning: true,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Periksa kembali selisih stok'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);

      await tester.tap(find.text('Periksa kembali selisih stok'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('ClosingInventorySummaryCard renders all 4 inventory metrics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClosingInventorySummaryCard(
              stokAwal: 375,
              barangMasuk: 10,
              terjual: 287,
              stokAkhir: 98,
            ),
          ),
        ),
      );

      expect(find.text('Ringkasan'), findsOneWidget);
      expect(find.text('Inventaris'), findsOneWidget);
      expect(find.text('375 pcs'), findsOneWidget);
      expect(find.text('10 pcs'), findsOneWidget);
      expect(find.text('287 pcs'), findsOneWidget);
      expect(find.text('98 pcs'), findsOneWidget);
    });

    testWidgets('ClosingSalesSummaryCard renders all sales breakdown rows', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClosingSalesSummaryCard(
              tunai: 820000,
              qris: 425000,
              transfer: 0,
              totalOmset: 1245000,
            ),
          ),
        ),
      );

      expect(find.text('Penjualan'), findsOneWidget);
      expect(find.text('Omzet Shift'), findsOneWidget);
      expect(find.text('Rp 820.000'), findsOneWidget);
      expect(find.text('Rp 425.000'), findsOneWidget);
      expect(find.text('Rp 1.245.000'), findsOneWidget);
    });

    testWidgets('AttendanceStatusBadge renders distinct colors and labels for closing statuses', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AttendanceStatusBadge(status: 'terverifikasi'),
                AttendanceStatusBadge(status: 'pending'),
                AttendanceStatusBadge(status: 'perlu_revisi'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Terverifikasi'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Perlu Revisi'), findsOneWidget);
    });
  });
}
