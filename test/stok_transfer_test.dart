import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pot_apps/core/models/lapak_model.dart';
import 'package:pot_apps/core/models/pengiriman_model.dart';
import 'package:pot_apps/core/models/produk_model.dart';
import 'package:pot_apps/core/models/stok_lapak_model.dart';
import 'package:pot_apps/core/models/user_model.dart';
import 'package:pot_apps/screens/penjualan_stok/repositories/penjualan_stok_repository.dart';
import 'package:pot_apps/screens/penjualan_stok/viewmodels/stok_transfer_view_model.dart';

class MockTransferRepository implements PenjualanStokRepository {
  List<StokLapakModel> mockStock = [
    const StokLapakModel(
      id: 'stok-1',
      lapakId: 'lapak-asal',
      produkId: 'prod-1',
      produk: ProdukModel(id: 'prod-1', nama: 'Pisang Madu Ori', harga: 15000),
      stokAwal: 20,
      stokMasuk: 10,
      stokTerjual: 5,
      stokTransfer: 5,
      stokAkhir: 20, // 20 + 10 - 5 - 5 = 20
    ),
    const StokLapakModel(
      id: 'stok-2',
      lapakId: 'lapak-asal',
      produkId: 'prod-2',
      produk: ProdukModel(id: 'prod-2', nama: 'Pisang Keju', harga: 18000),
      stokAwal: 5,
      stokMasuk: 0,
      stokTerjual: 5,
      stokTransfer: 0,
      stokAkhir: 0, // Out of stock
    ),
  ];

  List<LapakModel> mockStalls = [
    const LapakModel(id: 'lapak-asal', nama: 'Lapak Senayan (Asal)', lokasi: 'Jakarta'),
    const LapakModel(id: 'lapak-tujuan-1', nama: 'Lapak Galaxy', lokasi: 'Bekasi'),
    const LapakModel(id: 'lapak-tujuan-2', nama: 'Lapak Bintaro', lokasi: 'Tangerang'),
  ];

  List<UserModel> mockUsers = [
    const UserModel(
      id: 'user-kurir-1',
      nama: 'Budi Kurir',
      username: 'budi_kurir',
      email: 'budi@pot.id',
      role: 'viar',
      noHp: '08123456789',
      status: 'active',
      authProvider: 'local',
    ),
    const UserModel(
      id: 'user-unassigned-1',
      nama: 'User Baru',
      username: 'user_baru',
      email: 'baru@pot.id',
      role: 'unassigned',
      noHp: '08123456780',
      status: 'active',
      authProvider: 'local',
    ),
  ];

  bool transferCalled = false;
  Map<String, dynamic>? lastPayload;

  @override
  Future<List<StokLapakModel>> getStokLapak(String lapakId) async => mockStock;

  @override
  Future<List<LapakModel>> getAllLapak() async => mockStalls;

  @override
  Future<List<UserModel>> getAllUsers() async => mockUsers;

  @override
  Future<LapakModel?> getLapak(String lapakId) async {
    return mockStalls.where((l) => l.id == lapakId).firstOrNull;
  }

  @override
  Future<PengirimanModel> createTransferPengiriman({
    required String asalLapakId,
    required String tujuanLapakId,
    required String pengirimId,
    required DateTime tanggal,
    required List<Map<String, dynamic>> items,
    File? ttdPengirimFile,
  }) async {
    transferCalled = true;
    lastPayload = {
      'asalLapakId': asalLapakId,
      'tujuanLapakId': tujuanLapakId,
      'pengirimId': pengirimId,
      'tanggal': tanggal,
      'items': items,
    };
    return PengirimanModel(
      id: 'pg-101',
      uniqueId: '#PG-TRANS-101',
      lapakId: tujuanLapakId,
      asalLapakId: asalLapakId,
      pengirimId: pengirimId,
      tanggal: tanggal,
      status: 'draft',
      items: [],
    );
  }

  // Stubs for unused interface methods
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('StokLapakModel Transfer Conservation Invariant', () {
    test('calculateStokAkhir properly accounts for stokTransfer in balance', () {
      final json = {
        'id': 'stok-1',
        'lapak_id': 'lapak-1',
        'produk_id': 'prod-1',
        'stok_awal': 50,
        'stok_masuk': 20,
        'stok_terjual': 15,
        'stok_transfer': 10,
      };

      final model = StokLapakModel.fromJson(json);
      // 50 + 20 - 15 - 10 = 45
      expect(model.stokAwal, equals(50));
      expect(model.stokMasuk, equals(20));
      expect(model.stokTerjual, equals(15));
      expect(model.stokTransfer, equals(10));
      expect(model.stokAkhir, equals(45));
      expect(model.toJson()['stok_transfer'], equals(10));
    });
  });

  group('StokTransferViewModel State and Flow Tests', () {
    late MockTransferRepository repository;
    late StokTransferViewModel viewModel;
    const testOriginStall = LapakModel(id: 'lapak-asal', nama: 'Lapak Senayan (Asal)', lokasi: 'Jakarta');
    const testUser = UserModel(
      id: 'user-spg-1',
      nama: 'Siti SPG',
      username: 'siti_spg',
      email: 'siti@pot.id',
      role: 'spg',
      lapakId: 'lapak-asal',
      noHp: '08123456788',
      status: 'active',
      authProvider: 'local',
    );

    setUp(() {
      repository = MockTransferRepository();
      viewModel = StokTransferViewModel(
        currentUser: testUser,
        initialOriginStall: testOriginStall,
        repository: repository,
      );
    });

    test('initialize loads available origin stock and excludes origin stall from destinations', () async {
      await viewModel.initialize();

      // Only items with stokAkhir > 0 are available (prod-1 has 20, prod-2 has 0)
      expect(viewModel.availableOriginStock.length, equals(1));
      expect(viewModel.availableOriginStock.first.produkId, equals('prod-1'));

      // Destination stalls strictly excludes lapak-asal
      expect(viewModel.destinationStalls.length, equals(2));
      expect(viewModel.destinationStalls.any((l) => l.id == 'lapak-asal'), isFalse);

      // Courier is automatically assigned to current logged-in user creating the transfer DO
      expect(viewModel.selectedCourier?.id, equals(testUser.id));
    });

    test('stepper strictly caps transfer quantity at origin stock balance', () async {
      await viewModel.initialize();

      viewModel.updateQuantity('prod-1', 25, 20); // max is 20
      expect(viewModel.quantities['prod-1'], equals(20));

      viewModel.incrementQuantity('prod-1', 20);
      expect(viewModel.quantities['prod-1'], equals(20)); // cannot exceed 20

      viewModel.decrementQuantity('prod-1');
      expect(viewModel.quantities['prod-1'], equals(19));

      viewModel.updateQuantity('prod-1', 0, 20);
      expect(viewModel.quantities.containsKey('prod-1'), isFalse);
    });

    test('validates canProceedToStep2 and canSubmit requirements', () async {
      await viewModel.initialize();

      expect(viewModel.canProceedToStep2, isFalse);
      expect(viewModel.canSubmit, isFalse);

      // Add product
      viewModel.updateQuantity('prod-1', 5, 20);
      expect(viewModel.canProceedToStep2, isTrue);
      expect(viewModel.totalTransferUnits, equals(5));

      // Cannot submit yet without destination stall
      expect(viewModel.canSubmit, isFalse);

      // Select destination stall
      viewModel.setSelectedDestinationStall(viewModel.destinationStalls.first);
      expect(viewModel.canSubmit, isTrue); // Courier was preselected
    });

    test('submits transfer DO in draft status to repository', () async {
      await viewModel.initialize();
      viewModel.updateQuantity('prod-1', 5, 20);
      viewModel.setSelectedDestinationStall(viewModel.destinationStalls.first);

      final success = await viewModel.submitTransfer();
      expect(success, isTrue);
      expect(repository.transferCalled, isTrue);
      expect(repository.lastPayload?['asalLapakId'], equals('lapak-asal'));
      expect(repository.lastPayload?['tujuanLapakId'], equals('lapak-tujuan-1'));
      expect(repository.lastPayload?['items'], equals([{'produk_id': 'prod-1', 'qty': 5}]));
    });
  });
}
