import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pot_apps/core/models/lapak_model.dart';
import 'package:pot_apps/core/models/pengiriman_model.dart';
import 'package:pot_apps/core/models/penerimaan_model.dart';
import 'package:pot_apps/core/models/user_model.dart';
import 'package:pot_apps/screens/penerimaan/viewmodels/penerimaan_view_model.dart';
import 'package:pot_apps/screens/penerimaan/repositories/penerimaan_repository.dart';
import 'package:pot_apps/widgets/attendance/attendance_status_badge.dart';
import 'package:pot_apps/widgets/penerimaan/pengiriman_inspection_sheet.dart';
import 'package:pot_apps/widgets/penerimaan/penerimaan_detail_sheet.dart';

class MockPenerimaanRepo implements PenerimaanRepository {
  List<PengirimanModel> shipments = [];
  List<PenerimaanModel> receipts = [];

  @override
  Future<List<PengirimanModel>> getAvailableShipments({
    required String lapakId,
    String? status,
  }) async {
    return shipments;
  }

  @override
  Future<PengirimanModel> getShipmentDetail(String id) async {
    return shipments.firstWhere((s) => s.id == id);
  }

  @override
  Future<PengirimanModel> updateShipmentStatus({
    required String pengirimanId,
    required String status,
  }) async {
    final index = shipments.indexWhere((s) => s.id == pengirimanId);
    if (index != -1) {
      final updated = shipments[index].copyWith(status: status);
      shipments[index] = updated;
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
    throw UnimplementedError();
  }

  @override
  Future<PenerimaanModel> uploadNota({
    required String penerimaanId,
    required File photoFile,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<PenerimaanModel>> getReceiptHistory({
    String? spgId,
    String? lapakId,
    String? status,
  }) async {
    return receipts;
  }

  @override
  Future<LapakModel?> getLapak(String lapakId) async {
    return null;
  }
}

void main() {
  group('Bug 1: Status Badge Mapping Consistency', () {
    testWidgets('maps raw statuses to clean Indonesian labels', (tester) async {
      final statuses = {
        'dikirim': 'Di Jalan',
        'dikirim_viar': 'Di Jalan',
        'diterima_spg': 'Diterima SPG',
        'diterima': 'Diterima SPG',
        'draft': 'Draft',
        'selesai': 'Selesai',
        'sesuai': 'Sesuai',
        'selisih': 'Selisih',
      };

      for (final entry in statuses.entries) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AttendanceStatusBadge(status: entry.key),
            ),
          ),
        );
        expect(find.text(entry.value), findsOneWidget);
      }
    });
  });

  group('Bug 2 & 3: Bookmark Toggle and Real Backend Persistence', () {
    late MockPenerimaanRepo repo;
    late PenerimaanViewModel viewModel;

    setUp(() {
      repo = MockPenerimaanRepo();
      viewModel = PenerimaanViewModel(repository: repo);
    });

    test('ViewModel toggleShipmentStatus persists status changes to repository and updates list', () async {
      final testShipment = const PengirimanModel(
        id: 'SHIP-01',
        uniqueId: 'P-001',
        lapakId: 'LAPAK-1',
        status: 'dikirim_viar',
        qtyKirim: 10,
      );
      repo.shipments = [testShipment];

      const testUser = UserModel(
        id: 'USR-1',
        nama: 'SPG User',
        username: 'spg1',
        email: 'spg@pot.com',
        role: 'spg',
        lapakId: 'LAPAK-1',
        noHp: '081234567890',
        status: 'active',
        authProvider: 'local',
      );

      await viewModel.init(currentUser: testUser);
      expect(viewModel.allShipments.first.status, 'dikirim_viar');

      // Toggle to diterima_spg -> persists to backend repo
      final updated1 = await viewModel.toggleShipmentStatus('SHIP-01');
      expect(updated1?.status, 'diterima_spg');
      expect(viewModel.allShipments.first.status, 'diterima_spg');
      expect(repo.shipments.first.status, 'diterima_spg');

      // Refresh shipments simulates pull-to-refresh -> status stays 'diterima_spg'
      await viewModel.refreshShipments();
      expect(viewModel.allShipments.first.status, 'diterima_spg');

      // Toggle back to dikirim_viar -> persists to backend repo
      final updated2 = await viewModel.toggleShipmentStatus('SHIP-01');
      expect(updated2?.status, 'dikirim_viar');
      expect(viewModel.allShipments.first.status, 'dikirim_viar');
      expect(repo.shipments.first.status, 'dikirim_viar');
    });

    testWidgets('Inspection sheet disables Bookmark and Pilih button when shipment is draft',
        (tester) async {
      const draftShipment = PengirimanModel(
        id: 'SHIP-DRAFT',
        uniqueId: 'P-DRAFT',
        lapakId: 'LAPAK-1',
        status: 'draft',
        qtyKirim: 5,
      );

      bool selected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PengirimanInspectionSheet(
              initialShipment: draftShipment,
              loadDetail: (id) async => draftShipment,
              onSelectShipment: (s) => selected = true,
              onToggleStatus: (s) {},
            ),
          ),
        ),
      );

      // Verify "Pilih Pengiriman" button is present and tapping it does not invoke callback
      final pilihButton = find.text('Pilih Pengiriman');
      expect(pilihButton, findsOneWidget);
      await tester.tap(pilihButton);
      await tester.pump();
      expect(selected, isFalse);

      // Verify bookmark button tooltip is disabled
      expect(find.byTooltip('Tidak dapat menandai status Draft'), findsOneWidget);
    });

    testWidgets('Inspection sheet disables Bookmark and Pilih button when shipment is selesai',
        (tester) async {
      const selesaiShipment = PengirimanModel(
        id: 'SHIP-SELESAI',
        uniqueId: 'P-SELESAI',
        lapakId: 'LAPAK-1',
        status: 'selesai',
        qtyKirim: 5,
      );

      bool selected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PengirimanInspectionSheet(
              initialShipment: selesaiShipment,
              loadDetail: (id) async => selesaiShipment,
              onSelectShipment: (s) => selected = true,
              onToggleStatus: (s) {},
            ),
          ),
        ),
      );

      // Verify "Pilih Pengiriman" button is present and tapping it does not invoke callback
      final pilihButton = find.text('Pilih Pengiriman');
      expect(pilihButton, findsOneWidget);
      await tester.tap(pilihButton);
      await tester.pump();
      expect(selected, isFalse);

      // Verify bookmark button tooltip is disabled with selesai message
      expect(find.byTooltip('Pengiriman sudah selesai'), findsOneWidget);
    });

    testWidgets('Inspection sheet allows Bookmark toggle when shipment is dikirim_viar',
        (tester) async {
      const shipment = PengirimanModel(
        id: 'SHIP-ROAD',
        uniqueId: 'P-ROAD',
        lapakId: 'LAPAK-2',
        status: 'dikirim_viar',
        qtyKirim: 15,
      );

      PengirimanModel? toggledResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PengirimanInspectionSheet(
              initialShipment: shipment,
              loadDetail: (id) async => shipment,
              onSelectShipment: (s) {},
              onToggleStatus: (updated) => toggledResult = updated,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the bookmark icon button
      final bookmarkBtn = find.byTooltip('Tandai diterima SPG');
      expect(bookmarkBtn, findsOneWidget);

      await tester.tap(bookmarkBtn);
      await tester.pump();

      expect(toggledResult, isNotNull);
      expect(toggledResult!.status, 'diterima_spg');

      // Allow toast timer to complete cleanly
      await tester.pump(const Duration(seconds: 4));
    });
  });

  group('Riwayat Penerimaan: Detail Sheet Inspection', () {
    testWidgets('PenerimaanDetailSheet renders complete receipt information', (tester) async {
      final receipt = PenerimaanModel(
        id: 'REC-20261008-001',
        uniqueId: '#RC-20261008-001',
        pengirimanId: 'PG-20261008-005',
        qtyTerima: 25,
        status: 'sesuai',
        catatan: 'Barang diterima lengkap dan sesuai faktur.',
        tanggal: DateTime(2026, 10, 8),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PenerimaanDetailSheet(receipt: receipt),
          ),
        ),
      );

      // Check title and details
      expect(find.text('#RC-20261008-001'), findsOneWidget);
      expect(find.text('25 pcs'), findsOneWidget);
      expect(find.text('Barang diterima lengkap dan sesuai faktur.'), findsOneWidget);
      expect(find.text('Tutup'), findsOneWidget);
      expect(find.text('Sesuai'), findsNWidgets(2)); // Badge and verification label
    });
  });
}
