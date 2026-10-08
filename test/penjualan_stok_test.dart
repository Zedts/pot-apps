import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pot_apps/core/models/lapak_model.dart';
import 'package:pot_apps/core/models/penjualan_model.dart';
import 'package:pot_apps/core/models/produk_model.dart';
import 'package:pot_apps/core/models/stok_lapak_model.dart';
import 'package:pot_apps/core/models/user_model.dart';
import 'package:pot_apps/screens/penjualan_stok/repositories/penjualan_stok_repository.dart';
import 'package:pot_apps/screens/penjualan_stok/viewmodels/penjualan_stok_view_model.dart';
import 'package:pot_apps/widgets/penjualan_stok/stok_saat_ini_list_view.dart';

class MockPenjualanStokRepository implements PenjualanStokRepository {
  List<StokLapakModel> mockStock = [
    const StokLapakModel(
      id: 'stok-1',
      lapakId: 'lapak-1',
      produkId: 'prod-1',
      produk: ProdukModel(id: 'prod-1', nama: 'Mochi Sk', harga: 5000, status: 'aktif'),
      stokAwal: 10,
      stokMasuk: 20,
      stokTerjual: 5,
      stokAkhir: 25,
    ),
    const StokLapakModel(
      id: 'stok-2',
      lapakId: 'lapak-1',
      produkId: 'prod-2',
      produk: ProdukModel(id: 'prod-2', nama: 'Cokdub 15k', harga: 15000, status: 'aktif'),
      stokAwal: 5,
      stokMasuk: 10,
      stokTerjual: 2,
      stokAkhir: 13,
    ),
    const StokLapakModel(
      id: 'stok-3',
      lapakId: 'lapak-1',
      produkId: 'prod-3',
      produk: ProdukModel(id: 'prod-3', nama: 'Dubai Chuwy 30k', harga: 30000, status: 'aktif'),
      stokAwal: 10,
      stokMasuk: 50,
      stokTerjual: 10,
      stokAkhir: 50,
    ),
    const StokLapakModel(
      id: 'stok-4',
      lapakId: 'lapak-1',
      produkId: 'prod-4',
      produk: ProdukModel(id: 'prod-4', nama: 'Mochi Matcha 12k', harga: 12000, status: 'aktif'),
      stokAwal: 2,
      stokMasuk: 8,
      stokTerjual: 5,
      stokAkhir: 5,
    ),
    const StokLapakModel(
      id: 'stok-5',
      lapakId: 'lapak-1',
      produkId: 'prod-5',
      produk: ProdukModel(id: 'prod-5', nama: 'Mochi Coklat 8k', harga: 8000, status: 'aktif'),
      stokAwal: 5,
      stokMasuk: 15,
      stokTerjual: 2,
      stokAkhir: 18,
    ),
    const StokLapakModel(
      id: 'stok-6',
      lapakId: 'lapak-1',
      produkId: 'prod-6',
      produk: ProdukModel(id: 'prod-6', nama: 'Mochi Strawberry 10k', harga: 10000, status: 'aktif'),
      stokAwal: 1,
      stokMasuk: 3,
      stokTerjual: 2,
      stokAkhir: 2,
    ),
    // Out of stock product (stokAkhir: 0) - should NOT appear in availableStockItems
    const StokLapakModel(
      id: 'stok-7',
      lapakId: 'lapak-1',
      produkId: 'prod-7',
      produk: ProdukModel(id: 'prod-7', nama: 'Mochi Vanilla Habis', harga: 7000, status: 'aktif'),
      stokAwal: 5,
      stokMasuk: 0,
      stokTerjual: 5,
      stokAkhir: 0,
    ),
    // Belongs to another lapak - should NOT appear for lapak-1
    const StokLapakModel(
      id: 'stok-other',
      lapakId: 'lapak-other',
      produkId: 'prod-other',
      produk: ProdukModel(id: 'prod-other', nama: 'Produk Lapak Sebelah', harga: 9000, status: 'aktif'),
      stokAwal: 10,
      stokMasuk: 10,
      stokTerjual: 0,
      stokAkhir: 20,
    ),
  ];

  List<PenjualanModel> mockHistory = [];
  bool createCalled = false;

  @override
  Future<List<StokLapakModel>> getStokLapak(String lapakId) async => mockStock;

  @override
  Future<PenjualanModel> createPenjualan({
    required String lapakId,
    required String metodePembayaran,
    required List<Map<String, dynamic>> items,
    String? catatan,
    File? buktiFile,
  }) async {
    createCalled = true;
    final created = PenjualanModel(
      id: 'penjualan-test-1',
      totalHarga: 25000,
      metodePembayaran: metodePembayaran,
      buktiBayarUrl: buktiFile != null ? 'https://res.cloudinary.com/demo/image/upload/v1/bukti.jpg' : null,
      catatan: catatan ?? '',
      items: items.map((i) => PenjualanItemModel(
        id: 'item-1',
        produkId: i['produk_id'],
        namaProduk: 'Test Product',
        qty: i['qty'],
        hargaSatuan: 5000,
        subtotal: i['qty'] * 5000,
      )).toList(),
    );
    mockHistory.add(created);
    return created;
  }

  @override
  Future<PenjualanModel> uploadBuktiBayar({
    required String penjualanId,
    required File photoFile,
  }) async {
    return PenjualanModel(
      id: penjualanId,
      totalHarga: 25000,
      metodePembayaran: 'qris',
      buktiBayarUrl: 'https://res.cloudinary.com/demo/image/upload/v1/bukti.jpg',
    );
  }

  @override
  Future<List<PenjualanModel>> getSalesHistory({
    required String lapakId,
    String? spgId,
  }) async => mockHistory;

  @override
  Future<LapakModel?> getLapak(String lapakId) async {
    return const LapakModel(
      id: 'lapak-1',
      nama: 'Lapak Grand Galaxy',
      lokasi: 'Bekasi Selatan',
      latitude: -6.26,
      longitude: 106.97,
    );
  }
}

void main() {
  group('ProdukModel & StokLapakModel Tests', () {
    test('ProdukModel serializes and parses correctly', () {
      final json = {
        'id': 'p1',
        'nama': 'Mochi Matcha',
        'harga': 12000,
        'status': 'aktif',
      };
      final model = ProdukModel.fromJson(json);
      expect(model.id, 'p1');
      expect(model.nama, 'Mochi Matcha');
      expect(model.harga, 12000);
      expect(model.isAktif, true);
    });

    test('StokLapakModel calculates stok_akhir via formula invariant', () {
      final json = {
        'id': 's1',
        'lapak_id': 'l1',
        'produk_id': 'p1',
        'stok_awal': 10,
        'stok_masuk': 50,
        'stok_terjual': 15,
        // When stok_akhir is omitted, formula calculates: 10 + 50 - 15 = 45
      };
      final model = StokLapakModel.fromJson(json);
      expect(model.stokAwal, 10);
      expect(model.stokMasuk, 50);
      expect(model.stokTerjual, 15);
      expect(model.stokAkhir, 45);
    });
  });

  group('PenjualanModel & Items Tests', () {
    test('PenjualanModel parses items and payment methods properly', () {
      final json = {
        'id': 'pj-1',
        'tanggal': '2026-10-08T10:30:00Z',
        'total_harga': 45000,
        'metode_pembayaran': 'qris',
        'bukti_bayar_url': 'https://cloudinary.com/pot/bukti.jpg',
        'catatan': 'Pembeli langganan',
        'items': [
          {
            'id': 'it-1',
            'produk_id': 'p1',
            'nama_produk': 'Mochi Sk',
            'qty': 3,
            'harga_satuan': 5000,
            'subtotal': 15000,
          },
          {
            'id': 'it-2',
            'produk_id': 'p2',
            'nama_produk': 'Dubai Chuwy',
            'qty': 1,
            'harga_satuan': 30000,
            'subtotal': 30000,
          },
        ],
      };

      final model = PenjualanModel.fromJson(json);
      expect(model.id, 'pj-1');
      expect(model.totalHarga, 45000);
      expect(model.isQris, true);
      expect(model.isTunai, false);
      expect(model.resolvedBuktiUrl, 'https://cloudinary.com/pot/bukti.jpg');
      expect(model.items.length, 2);
      expect(model.totalQty, 4);
    });
  });

  group('PenjualanStokViewModel State & Stock Flow Tests', () {
    late MockPenjualanStokRepository mockRepo;
    late PenjualanStokViewModel vm;

    setUp(() {
      mockRepo = MockPenjualanStokRepository();
      const mockUser = UserModel(
        id: 'spg-1',
        nama: 'Siti SPG',
        username: 'sitispg',
        email: 'siti@pot.com',
        role: 'spg',
        lapakId: 'lapak-1',
        noHp: '08123456789',
        status: 'active',
        authProvider: 'local',
      );
      vm = PenjualanStokViewModel(currentUser: mockUser, repository: mockRepo);
    });

    test('initial state has tab 0 and empty cart', () {
      expect(vm.selectedTabIndex, 0);
      expect(vm.totalQuantity, 0);
      expect(vm.totalHarga, 0);
      expect(vm.hasSelectedProducts, false);
      expect(vm.canSubmit, false);
      expect(vm.selectedPaymentMethod, 'tunai');
      expect(vm.isViewingSelectedProducts, false);
    });

    test('availableStockItems filters out zero stock and other stalls', () async {
      await vm.initialize();
      // Total items in mock: 8.
      // - prod-7 has stokAkhir == 0 (excluded)
      // - prod-other has lapakId == lapak-other (excluded)
      // Remaining valid items: 6
      expect(vm.availableStockItems.length, 6);
      expect(vm.availableStockItems.every((item) => item.lapakId == 'lapak-1' && item.stokAkhir > 0), true);
    });

    test('prioritizedAvailableStockItems sorts descending by stokAkhir', () async {
      await vm.initialize();
      final sorted = vm.prioritizedAvailableStockItems;
      expect(sorted.length, 6);
      expect(sorted[0].produkId, 'prod-3'); // stock 50
      expect(sorted[1].produkId, 'prod-1'); // stock 25
      expect(sorted[2].produkId, 'prod-5'); // stock 18
      expect(sorted[3].produkId, 'prod-2'); // stock 13
      expect(sorted[4].produkId, 'prod-4'); // stock 5
      expect(sorted[5].produkId, 'prod-6'); // stock 2
    });

    test('quickPickStockItems limits initial display to top 5 products', () async {
      await vm.initialize();
      final top5 = vm.quickPickStockItems;
      expect(top5.length, 5);
      expect(top5.map((e) => e.produkId).toList(), ['prod-3', 'prod-1', 'prod-5', 'prod-2', 'prod-4']);
    });

    test('Phase A selection toggle controls hasSelectedProducts and count', () async {
      await vm.initialize();
      expect(vm.hasSelectedProducts, false);

      vm.toggleProductSelection('prod-3'); // Select Dubai Chuwy
      expect(vm.isProductSelected('prod-3'), true);
      expect(vm.hasSelectedProducts, true);
      expect(vm.selectedProductsCount, 1);
      expect(vm.getQuantity('prod-3'), 1);
      expect(vm.totalHarga, 30000);

      vm.toggleProductSelection('prod-1'); // Select Mochi Sk
      expect(vm.selectedProductsCount, 2);
      expect(vm.totalHarga, 35000);

      // Toggling prod-3 again deselects it
      vm.toggleProductSelection('prod-3');
      expect(vm.isProductSelected('prod-3'), false);
      expect(vm.selectedProductsCount, 1);
      expect(vm.totalHarga, 5000);
    });

    test('stepper strictly caps increment at available stock (stokAkhir)', () async {
      await vm.initialize();
      // prod-6 has stokAkhir: 2
      vm.toggleProductSelection('prod-6');
      expect(vm.getQuantity('prod-6'), 1);

      vm.incrementQuantity('prod-6');
      expect(vm.getQuantity('prod-6'), 2);
      expect(vm.errorMessage, isNull);

      // Attempt to increment past available stock (2)
      vm.incrementQuantity('prod-6');
      expect(vm.getQuantity('prod-6'), 2); // Still 2!
      expect(vm.errorMessage, contains('Jumlah tidak boleh melebihi sisa stok (2 pcs)'));
    });

    test('stepper decrement below 1 removes product from selected list', () async {
      await vm.initialize();
      vm.toggleProductSelection('prod-1'); // qty = 1
      expect(vm.hasSelectedProducts, true);

      vm.decrementQuantity('prod-1');
      expect(vm.getQuantity('prod-1'), 0);
      expect(vm.hasSelectedProducts, false);
      expect(vm.selectedProductsCount, 0);
    });

    test('one-tap trash button (removeProductSelection) removes product and resets view if empty', () async {
      await vm.initialize();
      vm.toggleProductSelection('prod-1');
      vm.toggleProductSelection('prod-2');
      vm.setViewingSelectedProducts(true);
      expect(vm.isViewingSelectedProducts, true);
      expect(vm.selectedProductsCount, 2);

      // Remove prod-1 via trash icon
      vm.removeProductSelection('prod-1');
      expect(vm.selectedProductsCount, 1);
      expect(vm.isProductSelected('prod-1'), false);
      expect(vm.isViewingSelectedProducts, true); // Still viewing because prod-2 remains

      // Remove prod-2 via trash icon
      vm.removeProductSelection('prod-2');
      expect(vm.selectedProductsCount, 0);
      expect(vm.hasSelectedProducts, false);
      // Automatically returns to Phase A when all items removed
      expect(vm.isViewingSelectedProducts, false);
    });

    test('validates canSubmit based on payment method and proof photo', () async {
      await vm.initialize();
      vm.toggleProductSelection('prod-1');

      // Cash (tunai) does not require photo proof
      vm.setPaymentMethod('tunai');
      expect(vm.isNonCash, false);
      expect(vm.canSubmit, true);

      // Non-cash (QRIS) requires photo proof
      vm.setPaymentMethod('qris');
      expect(vm.isNonCash, true);
      expect(vm.canSubmit, false); // No photo attached yet!

      // Non-cash (Transfer) requires photo proof
      vm.setPaymentMethod('transfer');
      expect(vm.isNonCash, true);
      expect(vm.canSubmit, false);
    });

    test('submits sales transaction and clears cart state', () async {
      await vm.initialize();
      vm.toggleProductSelection('prod-1');
      vm.incrementQuantity('prod-1'); // 2x prod-1 = 10,000

      final success = await vm.submitPenjualan();
      expect(success, true);
      expect(mockRepo.createCalled, true);
      expect(vm.totalQuantity, 0);
      expect(vm.hasSelectedProducts, false);
      expect(vm.isViewingSelectedProducts, false);
    });

    test('switches tabs and aggregates stock metrics', () async {
      await vm.initialize();
      vm.setTabIndex(1);
      expect(vm.selectedTabIndex, 1);

      // Total Awal: 10 + 5 + 10 + 2 + 5 + 1 + 5 + 10 = 48
      expect(vm.totalStokAwal, 48);
      // Total Masuk: 20 + 10 + 50 + 8 + 15 + 3 + 0 + 10 = 116
      expect(vm.totalStokMasuk, 116);
      // Total Terjual: 5 + 2 + 10 + 5 + 2 + 2 + 5 + 0 = 31
      expect(vm.totalStokTerjual, 31);
      // Total Akhir: 25 + 13 + 50 + 5 + 18 + 2 + 0 + 20 = 133
      expect(vm.totalStokAkhir, 133);
    });
  });

  group('StokSaatIniListView Widget Tests', () {
    testWidgets('renders search field, filters products by name, and shows empty message when not found', (tester) async {
      final mockRepo = MockPenjualanStokRepository();
      final vm = PenjualanStokViewModel(
        currentUser: const UserModel(
          id: 'spg-1',
          nama: 'SPG One',
          username: 'spg',
          email: 'spg@pot.com',
          role: 'spg',
          lapakId: 'lapak-1',
          noHp: '08123456789',
          status: 'active',
          authProvider: 'local',
        ),
        repository: mockRepo,
      );
      await vm.initialize();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StokSaatIniListView(viewModel: vm),
            ),
          ),
        ),
      );

      // Verify search input field exists with placeholder
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cari produk...'), findsOneWidget);

      // Initially all products are shown (e.g. Mochi Sk, Cokdub 15k)
      expect(find.text('Mochi Sk'), findsOneWidget);
      expect(find.text('Cokdub 15k'), findsOneWidget);

      // Search for "Cokdub"
      await tester.enterText(find.byType(TextField), 'Cokdub');
      await tester.pumpAndSettle();

      expect(find.text('Cokdub 15k'), findsOneWidget);
      expect(find.text('Mochi Sk'), findsNothing);
      expect(find.text('1 produk'), findsOneWidget);

      // Search for nonexistent product
      await tester.enterText(find.byType(TextField), 'Nonexistent Product XYZ');
      await tester.pumpAndSettle();

      expect(find.text('Produk tidak ditemukan'), findsOneWidget);
      expect(find.text('0 produk'), findsOneWidget);
    });
  });
}
