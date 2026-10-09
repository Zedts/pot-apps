import '../../../core/models/closing_model.dart';
import '../../../core/models/lapak_model.dart';
import '../../../core/models/penerimaan_model.dart';
import '../../../core/models/penjualan_model.dart';
import '../../../core/models/stok_lapak_model.dart';

/// Abstract repository contract for Daily Closing (Closingan) operations
abstract class ClosinganRepository {
  /// Fetch real-time stock balances for a stall (Lapak)
  Future<List<StokLapakModel>> getStokLapak(String lapakId);

  /// Fetch sales transactions for a stall on a specific date (YYYY-MM-DD)
  Future<List<PenjualanModel>> getSalesHistory({
    required String lapakId,
    String? tanggal,
    String? spgId,
  });

  /// Fetch goods receipts (Penerimaan) for a stall on a specific date (YYYY-MM-DD)
  Future<List<PenerimaanModel>> getReceiptHistory({
    required String lapakId,
    String? tanggal,
  });

  /// Fetch stall entity details
  Future<LapakModel?> getLapak(String lapakId);

  /// Create and submit a daily closing record
  Future<ClosingModel> createClosing(Map<String, dynamic> payload);

  /// Retrieve closing history records with optional filters
  Future<List<ClosingModel>> getClosingHistory({
    required String lapakId,
    String? spgId,
    String? tanggal,
    String? status,
  });

  /// Retrieve today's closing record if already submitted
  Future<ClosingModel?> getTodayClosing({
    required String lapakId,
    required String tanggal,
  });
}
