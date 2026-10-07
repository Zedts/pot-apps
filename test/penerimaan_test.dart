import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pot_apps/core/models/lapak_model.dart';
import 'package:pot_apps/core/models/penerimaan_model.dart';
import 'package:pot_apps/core/models/pengiriman_model.dart';
import 'package:pot_apps/core/models/user_model.dart';
import 'package:pot_apps/screens/penerimaan/repositories/penerimaan_repository.dart';
import 'package:pot_apps/screens/penerimaan/viewmodels/penerimaan_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock repository for testing ViewModel flows
class MockPenerimaanRepository implements PenerimaanRepository {
  List<PengirimanModel> shipmentsToReturn = [];
  PenerimaanModel? receiptToReturn;
  LapakModel? stallToReturn;

  @override
  Future<List<PengirimanModel>> getAvailableShipments({
    required String lapakId,
    String? status,
  }) async {
    return shipmentsToReturn;
  }

  @override
  Future<PengirimanModel> getShipmentDetail(String id) async {
    return shipmentsToReturn.firstWhere((s) => s.id == id);
  }

  @override
  Future<PengirimanModel> updateShipmentStatus({
    required String pengirimanId,
    required String status,
  }) async {
    final index = shipmentsToReturn.indexWhere((s) => s.id == pengirimanId);
    if (index != -1) {
      final updated = shipmentsToReturn[index].copyWith(status: status);
      shipmentsToReturn[index] = updated;
      return updated;
    }
    throw Exception('Shipment not found');
  }

  @override
  Future<PenerimaanModel> createPenerimaan({
    required String pengirimanId,
    required int qtyTerima,
    String? catatan,
    File? photoFile,
  }) async {
    return receiptToReturn ??
        PenerimaanModel(
          id: 'rcpt_001',
          pengirimanId: pengirimanId,
          spgId: 'spg_001',
          qtyTerima: qtyTerima,
          status: 'sesuai',
          catatan: catatan ?? '',
          tanggal: DateTime.now(),
        );
  }

  @override
  Future<PenerimaanModel> uploadNota({
    required String penerimaanId,
    required File photoFile,
  }) async {
    return receiptToReturn ??
        PenerimaanModel(
          id: penerimaanId,
          pengirimanId: 'ship_001',
          spgId: 'spg_001',
          qtyTerima: 10,
          status: 'sesuai',
          notaUrl: 'https://storage.googleapis.com/nota.jpg',
          tanggal: DateTime.now(),
        );
  }

  @override
  Future<List<PenerimaanModel>> getReceiptHistory({
    String? spgId,
    String? lapakId,
    String? status,
  }) async {
    return [];
  }

  @override
  Future<LapakModel?> getLapak(String lapakId) async {
    return stallToReturn;
  }
}

void main() {
  group('PengirimanModel Unit Tests', () {
    test('Correctly parses from JSON with nested items and metadata', () {
      final json = {
        'id': 'ship_001',
        'unique_id': '#PG-20261007-001',
        'lapak_id': 'lapak_123',
        'status': 'dikirim_viar',
        'qty_kirim': 45,
        'tanggal': '2026-10-07T08:30:00.000Z',
        'items': [
          {
            'id': 'item_1',
            'produk_id': 'prod_baklava',
            'nama_produk': 'Baklava Pistachio',
            'qty': 25,
            'jenis_satuan': 'box',
          },
          {
            'id': 'item_2',
            'produk_id': 'prod_delight',
            'nama_produk': 'Turkish Delight',
            'qty': 20,
            'jenis_satuan': 'pack',
          },
        ],
        'lapak': {
          'id': 'lapak_123',
          'nama': 'Lapak Malioboro',
        },
        'creator': {
          'id': 'viar_01',
          'nama': 'Ahmad (Kurir Viar)',
        },
      };

      final model = PengirimanModel.fromJson(json);

      expect(model.id, 'ship_001');
      expect(model.uniqueId, '#PG-20261007-001');
      expect(model.status, 'dikirim_viar');
      expect(model.qtyKirim, 45);
      expect(model.isDikirimViar, isTrue);
      expect(model.isDraft, isFalse);
      expect(model.isSelesai, isFalse);
      expect(model.items.length, 2);
      expect(model.items.first.namaProduk, 'Baklava Pistachio');
      expect(model.items.first.qty, 25);
      expect(model.items.first.jenisSatuan, 'box');
      expect(model.lapak?.nama, 'Lapak Malioboro');
      expect(model.creator?['nama'], 'Ahmad (Kurir Viar)');
    });

    test('Recognizes draft and selesai status flags', () {
      final draft = PengirimanModel(
        id: '1',
        uniqueId: '#PG-1',
        lapakId: 'l1',
        status: 'draft',
        qtyKirim: 10,
        tanggal: DateTime.now(),
      );
      expect(draft.isDraft, isTrue);
      expect(draft.isDikirimViar, isFalse);

      final selesai = PengirimanModel(
        id: '2',
        uniqueId: '#PG-2',
        lapakId: 'l1',
        status: 'selesai',
        qtyKirim: 10,
        tanggal: DateTime.now(),
      );
      expect(selesai.isSelesai, isTrue);
    });
  });

  group('ReceivedItemVerification Unit Tests', () {
    test('Calculates selisih difference and status correctly', () {
      const item = PengirimanItemModel(
        id: 'i1',
        pengirimanId: 'ship_001',
        produkId: 'prod_kopi',
        namaProduk: 'Kopi Turki',
        qty: 10,
        jenisSatuan: 'cup',
      );

      final verificationSesuai = ReceivedItemVerification(item: item, qtyTerima: 10);
      expect(verificationSesuai.isSelisih, isFalse);
      expect(verificationSesuai.selisihDiff, 0);

      final verificationKurang = ReceivedItemVerification(item: item, qtyTerima: 8);
      expect(verificationKurang.isSelisih, isTrue);
      expect(verificationKurang.selisihDiff, -2);

      final verificationLebih = ReceivedItemVerification(item: item, qtyTerima: 12);
      expect(verificationLebih.isSelisih, isTrue);
      expect(verificationLebih.selisihDiff, 2);
    });
  });

  group('PenerimaanModel Unit Tests', () {
    test('Parses from JSON and evaluates status', () {
      final json = {
        'id': 'rcpt_100',
        'pengiriman_id': 'ship_001',
        'unique_id': '#PG-20261007-001',
        'spg_id': 'spg_001',
        'qty_terima': 45,
        'status': 'sesuai',
        'catatan': 'Diterima dalam kondisi aman',
        'nota_url': 'https://pot.app/nota.pdf',
        'tanggal': '2026-10-07T09:00:00.000Z',
      };

      final model = PenerimaanModel.fromJson(json);

      expect(model.id, 'rcpt_100');
      expect(model.qtyTerima, 45);
      expect(model.isSesuai, isTrue);
      expect(model.isSelisih, isFalse);
      expect(model.catatan, 'Diterima dalam kondisi aman');
      expect(model.notaUrl, 'https://pot.app/nota.pdf');
    });
  });

  group('PenerimaanViewModel MVVM Tests', () {
    late MockPenerimaanRepository mockRepo;
    late PenerimaanViewModel viewModel;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      mockRepo = MockPenerimaanRepository();
      viewModel = PenerimaanViewModel(
        repository: mockRepo,
      );
    });

    test('Initializes state and filters top 5 non-selesai shipments', () async {
      mockRepo.shipmentsToReturn = List.generate(
        7,
        (i) => PengirimanModel(
          id: 'ship_$i',
          uniqueId: '#PG-20261007-00$i',
          lapakId: 'lapak_01',
          status: i == 6 ? 'selesai' : 'dikirim_viar',
          qtyKirim: 10 + i,
          tanggal: DateTime.now(),
        ),
      );

      final testUser = UserModel(
        id: 'spg_01',
        email: 'spg@pot.com',
        username: 'siti_spg',
        nama: 'Siti SPG',
        role: 'spg',
        lapakId: 'lapak_01',
        noHp: '081234567890',
        status: 'active',
        authProvider: 'local',
      );

      await viewModel.init(currentUser: testUser);

      expect(viewModel.allShipments.length, 7);
      // Quick pick excludes 'selesai' and takes at most 5 items
      expect(viewModel.quickPickShipments.length, 5);
      expect(viewModel.quickPickShipments.any((s) => s.isSelesai), isFalse);
      expect(viewModel.canSubmit, isFalse);
    });

    test('Selects shipment and computes received item verifications and discrepancy hints', () {
      final shipment = PengirimanModel(
        id: 'ship_detail',
        uniqueId: '#PG-DETAIL',
        lapakId: 'lapak_01',
        status: 'dikirim_viar',
        qtyKirim: 30,
        tanggal: DateTime.now(),
        items: const [
          PengirimanItemModel(
            id: 'i1',
            pengirimanId: 'ship_detail',
            produkId: 'prod_baklava',
            namaProduk: 'Baklava',
            qty: 20,
            jenisSatuan: 'box',
          ),
          PengirimanItemModel(
            id: 'i2',
            pengirimanId: 'ship_detail',
            produkId: 'prod_delight',
            namaProduk: 'Turkish Delight',
            qty: 10,
            jenisSatuan: 'pack',
          ),
        ],
      );

      viewModel.selectShipment(shipment);

      expect(viewModel.selectedShipment, isNotNull);
      expect(viewModel.canSubmit, isTrue);
      expect(viewModel.verifiedItems.length, 2);
      expect(viewModel.totalKirim, 30);
      expect(viewModel.totalTerima, 30);
      expect(viewModel.hasDiscrepancy, isFalse);
      expect(viewModel.discrepancyHintText, contains('Semua barang sesuai'));

      // Adjust Turkish Delight from 10 to 8 (Kurang 2)
      viewModel.updateItemQtyTerima(1, 8);

      expect(viewModel.totalTerima, 28);
      expect(viewModel.totalSelisih, 2);
      expect(viewModel.hasDiscrepancy, isTrue);
      expect(viewModel.discrepantItemNames, ['Turkish Delight']);
      expect(
        viewModel.discrepancyHintText,
        'hint: selisih 2 pada Turkish Delight',
      );
    });

    test('Cancel shipment selection resets state cleanly', () {
      final shipment = PengirimanModel(
        id: 'ship_detail',
        uniqueId: '#PG-DETAIL',
        lapakId: 'lapak_01',
        status: 'dikirim_viar',
        qtyKirim: 10,
        tanggal: DateTime.now(),
      );

      viewModel.selectShipment(shipment);
      expect(viewModel.selectedShipment, isNotNull);

      viewModel.cancelShipmentSelection();
      expect(viewModel.selectedShipment, isNull);
      expect(viewModel.verifiedItems.isEmpty, isTrue);
      expect(viewModel.canSubmit, isFalse);
    });

    test('Locks diterima_spg status via bookmark tracker', () {
      expect(viewModel.isStatusLocked('ship_100'), isFalse);
      viewModel.lockDiterimaStatus('ship_100');
      expect(viewModel.isStatusLocked('ship_100'), isTrue);
    });

    test('Captures or sets foto nota and clears it cleanly', () {
      final dummyFile = File('dummy_nota.jpg');
      viewModel.setFotoNota(dummyFile);
      expect(viewModel.capturedFotoNota, isNotNull);

      viewModel.clearFotoNota();
      expect(viewModel.capturedFotoNota, isNull);
    });

    test('Submits 2-step penerimaan and refreshes shipment list', () async {
      final testUser = UserModel(
        id: 'spg_01',
        email: 'spg@pot.com',
        username: 'siti_spg',
        nama: 'Siti SPG',
        role: 'spg',
        lapakId: 'lapak_01',
        noHp: '081234567890',
        status: 'active',
        authProvider: 'local',
      );
      await viewModel.init(currentUser: testUser);

      final shipment = PengirimanModel(
        id: 'ship_submit',
        uniqueId: '#PG-SUBMIT',
        lapakId: 'lapak_01',
        status: 'dikirim_viar',
        qtyKirim: 10,
        tanggal: DateTime.now(),
        items: const [
          PengirimanItemModel(
            id: 'i1',
            pengirimanId: 'ship_submit',
            produkId: 'p1',
            namaProduk: 'Kopi',
            qty: 10,
            jenisSatuan: 'box',
          ),
        ],
      );

      viewModel.selectShipment(shipment);
      viewModel.setCatatan('Catatan khusus penerimaan');

      final result = await viewModel.submitPenerimaan();

      expect(result, isNotNull);
      expect(result!.id, 'rcpt_001');
      expect(viewModel.selectedShipment, isNull);
      expect(viewModel.catatan, '');
      expect(viewModel.successMessage, contains('berhasil disimpan'));
    });
  });
}
