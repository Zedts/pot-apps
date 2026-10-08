import 'dart:io';
import '../../../core/models/lapak_model.dart';
import '../../../core/models/penjualan_model.dart';
import '../../../core/models/stok_lapak_model.dart';

/// Abstract repository contract for Stok & Penjualan operations
abstract class PenjualanStokRepository {
  /// Fetch real-time stock balances for a stall (Lapak)
  Future<List<StokLapakModel>> getStokLapak(String lapakId);

  /// Create a sales transaction and optionally upload payment proof
  Future<PenjualanModel> createPenjualan({
    required String lapakId,
    required String metodePembayaran,
    required List<Map<String, dynamic>> items,
    String? catatan,
    File? buktiFile,
  });

  /// Upload payment proof image for a sales transaction (QRIS/Transfer)
  Future<PenjualanModel> uploadBuktiBayar({
    required String penjualanId,
    required File photoFile,
  });

  /// Retrieve sales history for a lapak with optional SPG filter
  Future<List<PenjualanModel>> getSalesHistory({
    required String lapakId,
    String? spgId,
  });

  /// Retrieve lapak details
  Future<LapakModel?> getLapak(String lapakId);
}
